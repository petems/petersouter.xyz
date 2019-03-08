+++
author = "Peter Souter"
categories = ["Golang", "Coding", "Tech"]
date = 2019-03-07T11:14:19Z
description = ""
draft = false
thumbnailImage = "/images/2019/03/s3_progressbar_750.png"
coverImage = "/images/2019/03/s3_progressbar.png"
slug = "s3-download-progress-bar-in-golang"
tags = ["Tech", "Blog", "AWS", "Golang", "S3"]
title = "S3 Download Progress Bar in Golang"
+++

# S3 Download Progress Bar in Golang

Through a series of yak-shaves, I ended up needing to be able to do an S3 download on a machine without python on it, so I couldn't install the AWS CLI.

However, it could run a pre-compiled binary of something, which is easy to generate in Golang.

I was still tinkering around with Cobra and CLI apps, so I thought... how hard can it be?

## Proir Art

Unsurprisignly, there's a ton of existing code on Github for an AWS CLI tool in Golang. I even found a perfect example that had already implemented two of the bits I needed, `ls` and `cp` (listing and downloading), called [fasts3](https://github.com/tuneinc/fasts3). Not only did it implement the `s3` parts for AWS CLI, but it is actually faster doing tasks like `ls` because of it's use of golang channnels.

## Too quiet

So I forked off the original `fasts3` code and made a new project called [s3mini](https://github.com/petems/s3mini).

However, the code from fasts3 wasn't perfect: the way that `cp` worked wasn't 1:1 with the `aws` Python CLI - It didn't have a progress bar of the downloads occuring.

Not so bad if you were only downloading smaller files, but the terminal would be omniously empty whilst larger files were downloading.

## A little help from my friend...

After doing some digging, someone else had a similar request: "[service/s3/s3manager: Should be able to track download progress](https://github.com/aws/aws-sdk-go/issues/286)"

Looking at the code referenced, it looked like they'd got something working:

```
  bar := pb.New64(size).SetUnits(pb.U_BYTES)

  if d.showProgress {
    bar.Start()
  }
  etag := readMD5Sum(file)
  writer := &progressWriter{temp, bar}

  // Download the file using the AWS SDK
  params := &s3.GetObjectInput{
    Bucket:      &d.bucket,
    Key:         &key,
    IfNoneMatch: &etag,
  }
  if _, err := d.Download(writer, params); err != nil {
    if reqErr, ok := err.(awserr.RequestFailure); ok {
      if reqErr.StatusCode() == 304 {
        bar.Set64(bar.Total)
        bar.FinishPrint(fmt.Sprintf("Using local copy for %s", file))
        return nil
      }
    }
    return err
  }
  bar.FinishPrint(fmt.Sprintf("Downloaded %s", file))

  if err := os.Rename(temp.Name(), file); err != nil {
    panic(err)
  }
```

Honestly, I didn't really get how it was working... but the name of the Github user rang a bell... and I realised he was actually one of my colleagues at HashiCorp on the Packer team, Matt Whooker!

So I cheated a little and asked him to explain how it worked. His explanation helped a lot:

> the progress tracker implements the writer interface

> https://golang.org/pkg/io/#Writer
>
> so we treat the progress tracker as if it were actually the file we're writing to
>
> the tracker then turns around and writes the bytes its given to the real file
tracking how many bytes it wrote along the way
>
> well technically it's a `WriteAt` since I think there can be parallel download streams... https://golang.org/pkg/io/#WriterAt
>
> https://github.com/wercker/mhook/blob/master/mhook.go#L92-L100
>
> you can probably copy that wholesale and get the same result
> and just do a HEAD first if you're doing a single file download

Now I understood, and it helped me understand how interface writing in Golang works a bit more: we're essentially passing through the `writerAt`, adding to the progress bar's progress then allowing it to write to the file itself.

There was wone bit of the code I didn't understand:

```
if _, err := downloader.Download(writer, params); err != nil {
        if reqErr, ok := err.(awserr.RequestFailure); ok {
            if reqErr.StatusCode() == 304 {
                downloadBar.Set64(downloadBar.Total)
                downloadBar.FinishPrint(fmt.Sprintf("Using local copy for %s", filename))
                return nil
            }
        }
        return err
    }
```

I didn't want the 304 logic to test if it was already downloaded, so I did a little repurposing, and ended up with this:

```
bucket, key := parseS3Uri(s3Uri)

  filename := parseFilename(key)

  temp, err := ioutil.TempFile(destination, "s3mini-")
  if err != nil {
    panic(err)
  }

  size, err := getFileSize(svc, bucket, key)

  if err != nil {
    panic(err)
  }

  bar := pb.New64(size).SetUnits(pb.U_BYTES)
  bar.Start()

  writer := &progressWriter{writer: temp, pb: bar}

  params := &s3.GetObjectInput{
    Bucket: aws.String(bucket),
    Key:    aws.String(key),
  }

  tempfileName := temp.Name()

  if _, err := downloader.Download(writer, params); err != nil {
    bar.Set64(bar.Total)
    log.Printf("Download failed! Deleting tempfile: %s", tempfileName)
    os.Remove(tempfileName)
    panic(err)
  }

  bar.FinishPrint(fmt.Sprintf("Downloaded %s", filename))

  if err := temp.Close(); err != nil {
    panic(err)
  }

  if err := os.Rename(temp.Name(), filename); err != nil {
    panic(err)
  }
```

This worked perfectly, and in action, it looks something like this:

```
s3commander cp s3://hc-oss-test/go-getter/folder/main.tf .
 7 B / 7 B [=======================================] 100.00% 0s
Downloaded main.tf
```

## Giving back

Now I'd done the digging, I wanted to help out the next person who was doing this. [So I contributed an example back to the aws-sdk-go repo using the `pb` package](https://github.com/aws/aws-sdk-go/pull/2456)

The maintainers asked to remove the dependancy on the `pb` package, as they wanted the code not to pull in external packages if possible, which makes sense.

So after a bit of refeactoring, I ended up with this:

```
// progressWriter tracks the download progress of a file from S3 to a file
// as the writeAt method is called, the byte size is added to the written total,
// and then a log is printed of the written percentage from the total size
// it looks like this on the command line:
//  2019/02/22 12:59:15 File size:35943530 downloaded:16360 percentage:0%
//  2019/02/22 12:59:15 File size:35943530 downloaded:16988 percentage:0%
//  2019/02/22 12:59:15 File size:35943530 downloaded:33348 percentage:0%
type progressWriter struct {
  written int64
  writer  io.WriterAt
  size    int64
}

func (pw *progressWriter) WriteAt(p []byte, off int64) (int, error) {

  atomic.AddInt64(&pw.written, int64(len(p)))

  percentageDownloaded := int(float32(pw.written*100) / float32(pw.size))

  log.Printf("File size:%d downloaded:%d percentage:%d%% \n", pw.size, pw.written, percentageDownloaded)

  return pw.writer.WriteAt(p, off)
}

filename := parseFilename(key)

  sess, err := session.NewSession()

  if err != nil {
    panic(err)
  }

  s3Client := s3.New(sess)

  downloader := s3manager.NewDownloader(sess)

  size, err := getFileSize(s3Client, bucket, key)

  if err != nil {
    panic(err)
  }

  log.Printf("File size is: %s", byteCountDecimal(size))

  cwd, err := os.Getwd()
  if err != nil {
    panic(err)
  }

  temp, err := ioutil.TempFile(cwd, "getObjWithProgress-tmp-")

  tempfileName := temp.Name()

  if err != nil {
    panic(err)
  }

  writer := &progressWriter{writer: temp, size: size, written: 0}

  params := &s3.GetObjectInput{
    Bucket: aws.String(bucket),
    Key:    aws.String(key),
  }

  if _, err := downloader.Download(writer, params); err != nil {
    log.Printf("Download failed! Deleting tempfile: %s", tempfileName)
    os.Remove(tempfileName)
    panic(err)
  }

  if err := temp.Close(); err != nil {
    panic(err)
  }

  if err := os.Rename(temp.Name(), filename); err != nil {
    panic(err)
  }

  log.Printf("File downloaded! Avaliable at: %s", filename)
```

Which gives a noisier output (as it writes every time a bite is written) but works without external depedencies:

```
2019/02/22 12:59:15 File size:35943530 downloaded:16360 percentage:0%
2019/02/22 12:59:15 File size:35943530 downloaded:16988 percentage:0%
2019/02/22 12:59:15 File size:35943530 downloaded:33348 percentage:0%
```

That got merged, and hopefully it can help someone in the future!

## Conclusion

This whole attempt to was a great way of learning how `writerAt` worked and hopefully my example helps out the next person who wants to implement a progress bar for an S3 download tool.
