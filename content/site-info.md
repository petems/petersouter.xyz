---
title: Site Information
modified: "01-27-2026"
aliases:
- /about/site-info/
comments:       false
showMeta:       false
showActions:    false
showPagination: false
showSocial:     false
showDate:       false
---

Odds are if you have ended up on this site you found something interesting
or helpful. The following information gives insight on the tools and
technologies used on this site.

# Nerd facts

<article>

<details>
  <summary>This website is built using <u><a target="_blank" href="https://gohugo.io/">Hugo</a></u>.</summary>
  <p>Hugo is the backbone of this site. It is a powerful static site generator that allows me to write content in plain text. Hugo handles converting markdown, CSS, code blocks, and HTML snippets into a fast static website. Since this site is static, it's easy to modify and incredibly fast to serve. Prior to Hugo I was using the static generator <a target="_blank" href="https://jekyllrb.com/">Jekyll</a>.</p>
</details>
<details>
  <summary>All content is written in <u><a target="_blank" href="http://en.wikipedia.org/wiki/Markdown">Markdown</a></u>.</summary>
  <p>If you are not familiar with markdown, it allows me to write plain text in such a way that an engine can transform that text into rich HTML. This means I can write using any text editor I want (even vim if I so please) and create content without having to write all those dirty html tags. How many times have you forgotten to add that forward slash on an end tag resulting in a malformed page?</p>
</details>
<details>
  <summary>Hosting for this website is by <u><a target="_blank" href="https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html">AWS S3</a></u>.</summary>
  <p>AWS S3 allows me to store a bunch of files in a bucket and easily serve the static website. Hosting a website via Apache, Nginx, or IIS isn't rocket science, however by using AWS S3 it's dirt cheap with no server costs or maintenance overhead.</p>
</details>
<details>
  <summary>Site code can be found in the repo <u><a target="_blank" href="https://github.com/petems/petersouter.xyz">petersouter.xyz</a></u>.</summary>
  <p>I ❤️ Github. Git is such a nice version control system to work with. All content is publicly accessible for two reasons: 1) I want others to be able to see how this site was created. 2) Sharing this code means if you find something you like you are able to copy/paste working code. With that said, please don't blatantly steal written work of mine without crediting me.</p>
</details>
<details>
  <summary>Content delivery network provided by <u><a target="_blank" href="https://aws.amazon.com/cloudfront/">CloudFront</a></u>.</summary>
  <p>CloudFront connects into the rest of the AWS ecosystem really easily. This keeps the cost of this website down since everyone hits the cached content instead of the S3 bucket directly, which also helps with scale. It also means you get a nice and fast response time no matter where you are in the world.</p>
</details>
<details>
  <summary>Infrastructure is managed with <u><a target="_blank" href="https://www.terraform.io/">Terraform</a></u>.</summary>
  <p>All AWS infrastructure (S3, CloudFront, Route53, Certificate Manager) is defined as code using Terraform. This means the entire site infrastructure can be versioned, reviewed, and reproduced. The Terraform configurations are in the <code>terraform/</code> directory of the repository.</p>
</details>
<details>
  <summary>The theme for this website was created by <u><a target="_blank" href="https://github.com/kakawait">Thibaud Lepretre</a></u>.</summary>
  <p>The theme <a target="_blank" href="https://github.com/kakawait/hugo-tranquilpeak-theme/">tranquilpeak</a> is a gorgeous responsive theme for the Hugo blog framework.</p>
</details>
<details>
  <summary>GitHub Actions deploys my website <u><a target="_blank" href="https://github.com/petems/petersouter.xyz/actions">Build History</a></u>.</summary>
  <p>GitHub Actions is a CI/CD platform that automatically builds and deploys this site on every commit to the master branch. The workflow builds the Hugo site and uploads changed files to S3 using <a target="_blank" href="https://github.com/petems/go3up">go3up</a>, an intelligent S3 uploader that only uploads files that have changed based on MD5 checksums. Authentication uses AWS OIDC for secure, temporary credentials without storing static AWS keys.</p>
</details>
<details>
  <summary>User tracking is enabled and provided by <u><a target="_blank" href="https://www.google.com/analytics/">Google Analytics</a></u>.</summary>
  <p>I enable user tracking to understand viewership patterns. Knowing which articles are the most popular helps me when deciding what content I want to write about next.</p>
</details>
<details>
  <summary>Site comments are provided by <u><a target="_blank" href="https://disqus.com">Disqus</a></u>.</summary>
  <p>Disqus is a free service. It's widely used and allows users to login via different social media sites. What is not to like?</p>
</details>

</article>

<br>

# Why Static?
I really dislike CMS websites. When I see blogs that have code snippets that are a pain to view I cry a little. Sure Hugo and Jekyll are harder to get the way you want. Customizing it can be very time consuming and confusing. However, the payoff is full control and ultimate flexibility. Also, the extra overhead on my plate to create this website the way I have is both fun and I believe provides the best experience.

I have tried both Blogger and Wordpress prior to finally getting latched onto Jekyll (now Hugo). You won't find those sites...
