+++
author = "Peter Souter"
categories = ["Golang", "Testing", "Coding", "Tech"]
date = 2019-01-13T13:53:44Z
description = ""
draft = false
thumbnailImage = "/images/2019/01/golang_stdin_750.png"
coverImage = "/images/2019/01/golang_stdin.png"
slug = "testing-and-mocking-stdin-with-golang"
tags = ["Tech", "Blog", "Terraform", "Golang"]
title = "Testing and mocking stdin in Golang"
+++

# Testing and mocking stdin in Golang

I've been playing around with [cobra](https://github.com/spf13/cobra) recently, as it's an awesome library for CLI applications. I always like CLI apps for learning a language, so I've been tinkering with a CLI app to interact with Terraform Enterprise's API, which will force me to talking to external APIs, interpret the result and displaying it to the user.

## Testing, testing, 123

I want can show my application is tested and reliable. That's meant I've been learning how to test golang. I'm used to Ruby, which has some awesome tools (Mocha, Rspec, Stubbing, Webmock etc). It's possible to recreate that sort of experience in Golang, with tools like ginko, goconvey or golblin, but since we want to do things "The Golang way" I decided to try and stick to the most vanilla testing possible.

## passwordGetter

Ok, to start with I wanted a way of creating a configuration file based on input from the user. Cobra already has a great library for doing this, Viper, so the core logic of creating the file had already been handled, but I wanted to make things easy for the user: the ability to fetch input from the command prompt with some helpers. One of these elements was an API token.

To narrow down the main thing I was testing, I created a new CLI app called `passwordGetter`: it takes stdin input and then returns it to you.

I have a main package to call it on the CLI:

```
package main

import (
  "fmt"
  "os"

  "github.com/petems/passwordgetter/cmd"
)

func main() {
  fmt.Println("Enter password: ")
  result, err := cmd.Run()
  if err != nil {
    fmt.Printf("Something went wrong: %v", err)
    os.Exit(1)
  }

  fmt.Printf("\nYour password was: %s\n", result)
}
```

And a getter.go package:

```
package cmd

import (
  "bufio"
  "os"
)

func readPassword() (string, error) {
  scanner := bufio.NewScanner(os.Stdin)

  err := scanner.Err()

  if err != nil {
    return "", err
  }

  return scanner.Text(), nil
}

// Run reads string from stdin and returns that string
func Run() (string, error) {
  pwd, err := readPassword()
  if err != nil {
    return "", err
  }

  return string(pwd), nil
}
```

Pretty simple. But how do I write a test for the `run()` method?

## 1. Just unit test it

We're using plain ol' stdin here, which is an instance of the `io.Reader` type, so it's fairly easy to fix.

```
package cmd

import (
  "bufio"
  "io"
)

func readPassword(stdin io.Reader) (string, error) {
  reader := bufio.NewReader(stdin)
  text, err := reader.ReadString('\n')
  return text, err
}

// Run reads string from stdin and returns that string
func Run(stdin io.Reader) (string, error) {
  pwd, err := readPassword(stdin)
  if err != nil {
    return "", err
  }

  return string(pwd), nil
}
```

Then in main, We can pass in the `os.Stdin` object, which is a pointer to the file descriptor for the stdin:

```
func main() {
  fmt.Println("Enter password: ")
  result, err := cmd.Run(os.Stdin)
  if err != nil {
    fmt.Printf("Something went wrong: %v", err)
    os.Exit(1)
  }

  fmt.Printf("\nYour password was: %s\n", result)
}
```

## Writing a test for this

This is a pretty simple method to test as a unit.

We can create a `io.Reader` object as a byte array, write a value to it, then test that value matches the return from the method:

```
package cmd_test

import (
  "bytes"
  "testing"

  "github.com/petems/passwordgetter/cmd"
  "github.com/stretchr/testify/assert"
)

func TestRunReturnsPasswordInput(t *testing.T) {
  var stdin bytes.Buffer

  stdin.Write([]byte("hunter2\n"))

  result, err := cmd.Run(&stdin)
  assert.NoError(t, err)
  assert.Equal(t, "hunter2", result)
}
```

Pretty simple and works perfectly.

## When this doesn't work

This is all well and good for basic `stdin` reading. But since we're looking for a sensitive value, we probably want to hide the input in the terminal.

This is a pretty common usecase for stdin reading for passwords, so much so that there's already a function in the crypto golang library:

> `func ReadPassword(fd int) ([]byte, error)`
> ReadPassword reads a line of input from a terminal without local echo. This is commonly used for inputting passwords and other sensitive data. The slice returned does not include the \n.

We can use this in our code like so:

```
import (
  "bufio"
  "io"

  "golang.org/x/crypto/ssh/terminal"
)

func readPassword(fd int) (string, error) {
  pwd, error := terminal.ReadPassword(fd)
  return string(pwd), error
}

// Run reads string from stdin and returns that string
func Run(fd int) (string, error) {
  pwd, err := readPassword(fd)
  if err != nil {
    return "", err
  }

  return string(pwd), nil
}
```

Works great... but then how do we test it? We're no longer giving an `io.Reader` object, `readPassword` it takes an int of the Fd of the currently running process:

This means with a standard unit test, it always returns an empty string:

```
func TestRunReturnsPasswordInput(t *testing.T) {
  result, err := cmd.Run(os.Stdin.Fd())
  assert.NoError(t, err)
  assert.Equal(t, "hunter2", result)
}
```

Looking around online, I found a good response on StackEchange: https://stackoverflow.com/questions/38573176/mocking-crypto-ssh-terminal

> If you are stubbing this test by creating a fake file that os.Stdin is referencing, your tests will become tremendously OS specific when you try to handle ReadPassword(). This is because under the hood Go is compiling separate syscalls depending on the OS. ReadPassword() is implemented here:

```
func ReadPassword(fd int) ([]byte, error) {
  var oldState syscall.Termios
  if _, _, err := syscall.Syscall6(syscall.SYS_IOCTL, uintptr(fd), ioctlReadTermios, uintptr(unsafe.Pointer(&oldState)), 0, 0, 0); err != 0 {
    return nil, err
  }
```
> ##### Taken from https://github.com/golang/crypto/blob/911fafb28f4ee7c7bd483539a6c96190bbbccc3f/ssh/terminal/util.go#L94

> but the syscalls based on architecture and OS are in this directory. As you can see there are many. I cannot think of a good way to stub this test in the way you are specifying.

Bummer! So...what can we do?

> With the limited understanding of your problem the solution I would propose would be to inject a simple interface
> This way you can pass in a fake object to your tests, and stub the response to ReadPassword. I know this feels like writing your code for your tests, but you can reframe this thought as terminal is an outside dependency (I/O) that should be injected! So now your tests are not only ensuring your code works, but actually helping you make good design decisions.

Ok, so lets try that:

```
package cmd

import (
  "syscall"

  "golang.org/x/crypto/ssh/terminal"
)

// PasswordReader returns password read from a reader
type PasswordReader interface {
  ReadPassword() (string, error)
}

// StdInPasswordReader default stdin password reader
type StdInPasswordReader struct {
}

// ReadPassword reads password from stdin
func (pr StdInPasswordReader) ReadPassword(pr PasswordReader) (string, error) {
  pwd, error := terminal.ReadPassword(int(syscall.Stdin))
  return string(pwd), error
}

func readPassword(pr PasswordReader) (string, error) {
  pwd, err := pr.ReadPassword()
  if err != nil {
    return "", err
  }
  return pwd, nil
}

// Run reads string from stdin and returns that string
func Run(pr PasswordReader) (string, error) {
  pwd, err := readPassword(pr)
  if err != nil {
    return "", err
  }

  return string(pwd), nil
}
```

Now we can actually test ReadPassword function by defining a new struct that fulfills the PasswordReader interface with a method which we are controlling. This means in our tests we can stub the behavior of the method.

We now have two choices on how to write a test for this:

## 1. Mock it ourselves

The more manual approach is to mock the calls within the code ourselves. Create a new struct which we can control. We can even stub out error returns.

```
// getter_test.go

package cmds

import (
  "errors"
  "testing"

  "github.com/petems/passwordgetter/cmd"
  "github.com/stretchr/testify/assert"
)

type stubPasswordReader struct {
  Password string
  ReturnError error
}

func (pr stubPasswordReader) ReadPassword() (string, error) {
  if pr.ReturnError {
    return "", error.new("stubbed error")
  }
  return pr.Password, nil
}

func TestRunReturnsErrorWhenReadPasswordFails(t *testing.T) {
  pr := stubPasswordReader{ReturnError: true}
  result, err := cmd.Run(errorReader)
  assert.Error(t, err)
  assert.Equal(t, errors.New("stubbed error"), err)
  assert.Equal(t, "", result)
}

func TestRunReturnsPasswordInput(t *testing.T) {
  pr := stubPasswordReader{Password: "password"}
  result, err := cmd.Run(pr)
  assert.NoError(t, err)
  assert.Equal(t, "password", result)
}
```

This works fine, but it's not super fun having to write out the stub logic for each test.

If only there was a way to do this automatically...

## Mock generators: gomock, counterFeiter and testify/mock

There are a number of different mocking tools out there but they all work in the same way: generate mock code based on the interface, then use custom methods to control the behaviour of the mocked interface. We can even use the `go generate` command so we can hae a task to generate these as things change.

For our code, this is a little overkill to be honest: we have a method that's only doing one thing, it's probably not a huge deal to write out the stub code within the test. But for learning's sake, we can try it ourselves.

### gomock

Gomock is the fairly official way of doing this, it's under the official Github org. So lets try that first:

So we add a generator step into the code:

```
//go:generate mockgen -destination=../mocks/mock_getter.go -package=mocks github.com/petems/passwordgetter/cmd PasswordReader
```

This will create a new file under `./mocks/mock_getter.go`:

```
// Code generated by MockGen. DO NOT EDIT.
// Source: github.com/petems/passwordgetter/cmd (interfaces: PasswordReader)

// Package mocks is a generated GoMock package.
package mocks

import (
	gomock "github.com/golang/mock/gomock"
	reflect "reflect"
)

// MockPasswordReader is a mock of PasswordReader interface
type MockPasswordReader struct {
	ctrl     *gomock.Controller
	recorder *MockPasswordReaderMockRecorder
}

// MockPasswordReaderMockRecorder is the mock recorder for MockPasswordReader
type MockPasswordReaderMockRecorder struct {
	mock *MockPasswordReader
}

// NewMockPasswordReader creates a new mock instance
func NewMockPasswordReader(ctrl *gomock.Controller) *MockPasswordReader {
	mock := &MockPasswordReader{ctrl: ctrl}
	mock.recorder = &MockPasswordReaderMockRecorder{mock}
	return mock
}

// EXPECT returns an object that allows the caller to indicate expected use
func (m *MockPasswordReader) EXPECT() *MockPasswordReaderMockRecorder {
	return m.recorder
}

// ReadPassword mocks base method
func (m *MockPasswordReader) ReadPassword() (string, error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "ReadPassword")
	ret0, _ := ret[0].(string)
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// ReadPassword indicates an expected call of ReadPassword
func (mr *MockPasswordReaderMockRecorder) ReadPassword() *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "ReadPassword", reflect.TypeOf((*MockPasswordReader)(nil).ReadPassword))
}
```

Then in our test, we add the mock into the imports:

```
import (

  "testing"
  "errors"

  "github.com/golang/mock/gomock"
  "github.com/petems/passwordgetter/mocks"
  "github.com/petems/passwordgetter/cmd"
)
```

Then we mock out the calls:

```
  mockCtrl := gomock.NewController(t)
  defer mockCtrl.Finish()

  mockPasswordReader := mocks.NewMockPasswordReader(mockCtrl)

  mockPasswordReader.EXPECT().ReadPassword().Return("", nil).Times(1)
```

Then we write the test over:

```
func TestRunReturnsErrorWhenEmptyString(t *testing.T) {

  mockCtrl := gomock.NewController(t)
  defer mockCtrl.Finish()

  mockPasswordReader := mocks.NewMockPasswordReader(mockCtrl)

  mockPasswordReader.EXPECT().ReadPassword().Return("", nil).Times(1)

  result, err := cmd.Run(mockPasswordReader)
  assert.Error(t, err)
  assert.Equal(t, errors.New("empty password provided"), err)
  assert.Equal(t, "", result)
}
```

And viola: We have the stdin behaviour

## counterfeiter

Counterfeiter works in a similar way:

```
//go:generate counterfeiter -o ../fakes/password_reader.go . PasswordReader
```

Which generates a "fake":

```
// Code generated by counterfeiter. DO NOT EDIT.
package fakes

import (
	"sync"

	"github.com/petems/passwordgetter/cmd"
)

type FakePasswordReader struct {
	ReadPasswordStub        func() (string, error)
	readPasswordMutex       sync.RWMutex
	readPasswordArgsForCall []struct {
	}
	readPasswordReturns struct {
		result1 string
		result2 error
	}
	readPasswordReturnsOnCall map[int]struct {
		result1 string
		result2 error
	}
	invocations      map[string][][]interface{}
	invocationsMutex sync.RWMutex
}

func (fake *FakePasswordReader) ReadPassword() (string, error) {
	fake.readPasswordMutex.Lock()
	ret, specificReturn := fake.readPasswordReturnsOnCall[len(fake.readPasswordArgsForCall)]
	fake.readPasswordArgsForCall = append(fake.readPasswordArgsForCall, struct {
	}{})
	fake.recordInvocation("ReadPassword", []interface{}{})
	fake.readPasswordMutex.Unlock()
	if fake.ReadPasswordStub != nil {
		return fake.ReadPasswordStub()
	}
	if specificReturn {
		return ret.result1, ret.result2
	}
	fakeReturns := fake.readPasswordReturns
	return fakeReturns.result1, fakeReturns.result2
}

func (fake *FakePasswordReader) ReadPasswordCallCount() int {
	fake.readPasswordMutex.RLock()
	defer fake.readPasswordMutex.RUnlock()
	return len(fake.readPasswordArgsForCall)
}

func (fake *FakePasswordReader) ReadPasswordCalls(stub func() (string, error)) {
	fake.readPasswordMutex.Lock()
	defer fake.readPasswordMutex.Unlock()
	fake.ReadPasswordStub = stub
}

func (fake *FakePasswordReader) ReadPasswordReturns(result1 string, result2 error) {
	fake.readPasswordMutex.Lock()
	defer fake.readPasswordMutex.Unlock()
	fake.ReadPasswordStub = nil
	fake.readPasswordReturns = struct {
		result1 string
		result2 error
	}{result1, result2}
}

func (fake *FakePasswordReader) ReadPasswordReturnsOnCall(i int, result1 string, result2 error) {
	fake.readPasswordMutex.Lock()
	defer fake.readPasswordMutex.Unlock()
	fake.ReadPasswordStub = nil
	if fake.readPasswordReturnsOnCall == nil {
		fake.readPasswordReturnsOnCall = make(map[int]struct {
			result1 string
			result2 error
		})
	}
	fake.readPasswordReturnsOnCall[i] = struct {
		result1 string
		result2 error
	}{result1, result2}
}

func (fake *FakePasswordReader) Invocations() map[string][][]interface{} {
	fake.invocationsMutex.RLock()
	defer fake.invocationsMutex.RUnlock()
	fake.readPasswordMutex.RLock()
	defer fake.readPasswordMutex.RUnlock()
	copiedInvocations := map[string][][]interface{}{}
	for key, value := range fake.invocations {
		copiedInvocations[key] = value
	}
	return copiedInvocations
}

func (fake *FakePasswordReader) recordInvocation(key string, args []interface{}) {
	fake.invocationsMutex.Lock()
	defer fake.invocationsMutex.Unlock()
	if fake.invocations == nil {
		fake.invocations = map[string][][]interface{}{}
	}
	if fake.invocations[key] == nil {
		fake.invocations[key] = [][]interface{}{}
	}
	fake.invocations[key] = append(fake.invocations[key], args)
}

var _ cmd.PasswordReader = new(FakePasswordReader)
```

Which we can then refer to in our tests:

```
import (
	"errors"
	"testing"

	"github.com/petems/passwordgetter/cmd"
	"github.com/petems/passwordgetter/fakes"
	"github.com/stretchr/testify/assert"
)
```

We then control the output from the fake:

```
		pr := &fakes.FakePasswordReader{}
		pr.ReadPasswordReturns("password", nil)
```

I ended up refactoring this into a [table-driven-test](https://github.com/golang/go/wiki/TableDrivenTests) also, just to make the test a bit easier to read:

```
package cmd_test

import (
	"errors"
	"testing"

	"github.com/petems/passwordgetter/cmd"
	"github.com/petems/passwordgetter/fakes"
	"github.com/stretchr/testify/assert"
)

type runTest struct {
	PasswordReaderValue string
	PasswordReaderError error
	expectedResult      string
	expectedError       error
}

var runTests = []runTest{
	{"hunter2", nil, "hunter2", nil},
	{"", nil, "", errors.New("empty password provided")},
	{"ERR", errors.New("stubbed error"), "", errors.New("stubbed error")},
}

func TestRun(t *testing.T) {
	for _, tt := range runTests {
		pr := &fakes.FakePasswordReader{}
		pr.ReadPasswordReturns(tt.PasswordReaderValue, tt.PasswordReaderError)
		actualReturn, actualError := cmd.Run(pr)
		if tt.expectedError != nil {
			assert.Error(t, actualError)
			assert.Equal(t, actualError, tt.expectedError)
		}
		if actualReturn != tt.expectedResult {
			assert.NoError(t, actualError)
			assert.Equal(t, actualReturn, tt.expectedResult)
		}
	}
}
```

I actully like the faking implemenation a little better than gomock, it just looks more natural?

## Alternative approaches

One thing I've been playing with for `stdin` in particular, would be to use something like [go-expect](https://github.com/Netflix/go-expect).

This is a pure golang implementation of the expect tool, allowing us to create an object that inputs to stdin and returns based on output:

```
import (
	"log"
	"os"
	"os/exec"
	"time"

	expect "github.com/Netflix/go-expect"
)

func main() {
  c, err := expect.NewConsole(expect.WithStdout(os.Stdout))
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()

	cmd := exec.Command("vi")
	cmd.Stdin = c.Tty()
	cmd.Stdout = c.Tty()
	cmd.Stderr = c.Tty()

	go func() {
		c.ExpectEOF()
	}()

	err = cmd.Start()
	if err != nil {
		log.Fatal(err)
	}

	time.Sleep(time.Second)
	c.Send("iHello world\x1b")
	time.Sleep(time.Second)
	c.Send("dd")
	time.Sleep(time.Second)
	c.SendLine(":q!")

	err = cmd.Wait()
	if err != nil {
		log.Fatal(err)
  }
}
```

At this point, we would be pretty close to integration testing level, so we probably want to avoid this for unit tests, but it might prove useful for `stdin` tests in the future.

## Conclusion

This has given me a good understanding of mocking external calls in Golang. My code is available here: https://github.com/petems/passwordgetter
