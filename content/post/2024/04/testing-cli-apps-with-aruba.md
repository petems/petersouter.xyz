+++
author = "Peter Souter"
categories = ["Tech"]
date = 2024-04-09T13:28:00Z
description = ""
draft = false
thumbnailImage = "/images/2024/04/aruba.png"
coverImage = "/images/2024/04/aruba-cover.png"
slug = "testing-cli-apps-with-aruba"
tags = ["Tech", "Blog", "Ruby", "Testing"]
title = "Testing CLI apps with Aruba (Ruby or Not)"
+++

## CLI Acceptance Testing 

One of my hobbies is writing little CLI apps to create workflows, automate and solve issues I'm having. The one I've probably tinkered with the most is [gitsweeper](https://github.com/petems/gitsweeper). Gitsweeper is a golang re-write of [git-sweep](https://github.com/arc90/git-sweep), a python CLI tool I'd been using for a while to clean up branches that had been merged into the master branch. 

Because these apps are very small and self-contained, I want to be able to extensively test the happy and sad paths. For something like gitsweeper, there are a number of scenarios and edge cases to test against: A non-existent git repo, no branches being available, lack of permissions and so on.

Writing unit tests in go is pretty self-explanatory, but acceptance tests don't really grok as much for me. It feels like you have to write a lot of code to test even the simplest of scenarios. 

What would really help would be a tool that is specifically designed to test CLI applications, and already has a lot of the usecases we'd need such as checking exit codes and giving input already implemented.

Honestly, I'm not a golang developer, I just like it for CLI apps as there's a huge amount of library support and it creates self-contained binaries without the need for golang itself needing to be installed. 

Previously, I was a Ruby developer, and when I was using Ruby I was a heavy Cucumber user, and wrote a number of Gherkin feature files for testing. One of the CLI apps I was working on used Aruba, and I've since used it for a number of CLI projects.

## Aruba

[Aruba](https://github.com/cucumber/aruba) is a Cucumber extension for testing command-line applications and whilst it's designed for Ruby applications, it can technically work in any language.

What makes it so useful is out of the box it handles a lot of the various usecases you'd need to test a command line apps. Things like passing arguments, interacting with the file system, capturing exit codes and mimicking interactive usage are all available natively. 

Essentially there are a number of pre-written Aruba specific step definitions that are CLI and filesystem focused:

### Givens
1. `Given /The default aruba timeout is (\d+) seconds/`
2. `Given /^I'm using a clean gemset "([^"]*)"$/`
3. `Given /^a directory named "([^"]*)"$/`
4. `Given /^a file named "([^"]*)" with:$/`
5. `Given /^a (\d+) byte file named "([^"]*)"$/`
6. `Given /^an empty file named "([^"]*)"$/`

### Whens
1. `When /^I write to "([^"]*)" with:$/`
2. `When /^I overwrite "([^"]*)" with:$/`
3. `When /^I append to "([^"]*)" with:$/`
4. `When /^I append to "([^"]*)" with "([^"]*)"$/`
5. `When /^I remove the file "([^"]*)"$/`
6. `When /^I cd to "([^"]*)"$/`
7. `When /^I run "(.*)"$/` (Depreciated. Use #8 below instead.)
8. `When /^I run `([^`]*)`$/`
9. `When /^I successfully run "(.*)"$/` (Depreciated. Use #10 below instead.)
10. `When /^I successfully run `(.*?)`(?: for up to (\d+) seconds)?$/`
11. `When /^I run "([^"]*)" interactively$/` (Depreciated. User #12 below instead.)
12. `When /^I run `([^`]*)` interactively$/`
13. `When /^I type "([^"]*)"$/`
14. `When /^I wait for (?:output|stdout) to contain "([^"]*)"$/`

### Thens
1. `Then /^the output should contain "([^"]*)"$/`
2. `Then /^the output from "([^"]*)" should contain "([^"]*)"$/`
3. `Then /^the output from "([^"]*)" should not contain "([^"]*)"$/`
4. `Then /^the output should not contain "([^"]*)"$/`
5. `Then /^the output should contain:$/`
6. `Then /^the output should not contain:$/`
7. `Then /^the output(?: from "(.*?)")? should contain exactly "(.*?)"$/`
8. `Then /^the output(?: from "(.*?)")? should contain exactly:$/`
9. `Then /^the output should match \/([^\/]*)\/$/`
10. `Then /^the output should match:$/`
11. `Then /^the output should not match \/([^\/]*)\/$/`
12. `Then /^the output should not match:$/`
13. `Then /^the exit status should be (\d+)$/`
14. `Then /^the exit status should not be (\d+)$/`
15. `Then /^it should (pass|fail) with:$/`
16. `Then /^it should (pass|fail) with exactly:$/`
17. `Then /^it should (pass|fail) with regexp?:$/`
18. `Then /^the stderr(?: from "(.*?)")? should contain( exactly)? "(.*?)"$/`
19. `Then /^the stderr(?: from "(.*?)")? should contain( exactly)?:$/`
20. `Then /^the stdout(?: from "(.*?)")? should contain( exactly)? "(.*?)"$/`
21. `Then /^the stdout(?: from "(.*?)")? should contain( exactly)?:$/`
22. `Then /^the stderr should not contain "([^"]*)"$/`
23. `Then /^the stderr should not contain:$/`
24. `Then /^the (stderr|stdout) should not contain anything$/`
25. `Then /^the stdout should not contain "([^"]*)"$/`
26. `Then /^the stdout should not contain:$/`
27. `Then /^the stdout from "([^"]*)" should not contain "([^"]*)"$/`
28. `Then /^the stderr from "([^"]*)" should not contain "([^"]*)"$/`
29. `Then /^the file "([^"]*)" should not exist$/`
30. `Then /^the following files should exist:$/`
31. `Then /^the following files should not exist:$/`
32. `Then /^a file named "([^"]*)" should exist$/`
33. `Then /^a file named "([^"]*)" should not exist$/`
34. `Then /^a (\d+) byte file named "([^"]*)" should exist$/`
35. `Then /^the following directories should exist:$/`
36. `Then /^the following directories should not exist:$/`
37. `Then /^a directory named "([^"]*)" should exist$/`
38. `Then /^a directory named "([^"]*)" should not exist$/`
39. `Then /^the file "([^"]*)" should contain "([^"]*)"$/`
40. `Then /^the file "([^"]*)" should not contain "([^"]*)"$/`
41. `Then /^the file "([^"]*)" should contain:$/`
42. `Then /^the file "([^"]*)" should contain exactly:$/`
43. `Then /^the file "([^"]*)" should match \/([^\/]*)\/$/`
44. `Then /^the file "([^"]*)" should not match \/([^\/]*)\/$/`

If we need to do anything not specified here, we can write custom step definitons, such as setting up a Docker image to run our test suite against.

## Writing an Aruba feature for a Golang app

Getting started with our gitsweeper app, the simplest thing we want to do is validate the application builds and it runs. 

So lets write that out as a Gherkin feature file:

```gherkin
Feature: Version Command

  Background:
    Given I have "go" command installed
    And a build of gitsweeper
    Then the build should be present

  Scenario:
    Given a build of gitsweeper
    When I run `gitsweeper-int-test`
    Then the output should contain:
      """"
      usage: gitsweeper [<flags>] <command> [<args> ...]

      A command-line tool for cleaning up merged branches.
      """"
```

Some of these are using the in-built Aruba matchers, such as `the output should contain`, but other's we have to define. 

If we do a `bundle exec cucumber .` run, we should get prompted on which ones to create:

```shell
$ bundle exec cucumber features/no_argument.feature
Using the default profile...
Feature: Version Command

  Background:                           # features/no_argument.feature:3
    Given I have "go" command installed # features/no_argument.feature:4
    And a build of gitsweeper           # features/no_argument.feature:5
    Then the build should be present    # features/no_argument.feature:6

  Scenario:                          # features/no_argument.feature:8
    Given a build of gitsweeper      # features/no_argument.feature:9
    When I run `gitsweeper-int-test` # aruba-b9d0f15d1292/lib/aruba/cucumber/command.rb:3
    Then the output should contain:  # aruba-b9d0f15d1292/lib/aruba/cucumber/command.rb:213
      """
      usage: gitsweeper [<flags>] <command> [<args> ...]

      A command-line tool for cleaning up merged branches.
      """

1 scenario (1 undefined)
6 steps (2 skipped, 4 undefined)
0m0.004s

You can implement step definitions for undefined steps with these snippets:

Given('I have {string} command installed') do |string|
  pending # Write code here that turns the phrase above into concrete actions
end

Given('a build of gitsweeper') do
  pending # Write code here that turns the phrase above into concrete actions
end

Then('the build should be present') do
  pending # Write code here that turns the phrase above into concrete actions
end
```

We can then write these supporting steps in our `/step_definitions/gitsweeper_steps.rb` file:

```ruby
Given(/^I have "([^"]*)" command installed$/) do |command|
  is_present = system("which #{ command} > /dev/null 2>&1")
  raise "Command #{command} is not present in the system" if not is_present
end

Then('the build should be present') do
  steps %Q(
    Then a file named "#{$bin_dir}/gitsweeper-int-test" should exist
  )
end

Given("a build of gitsweeper") do
  raise 'gitsweeper build failed' unless system("go build -o bin/gitsweeper-int-test main.go")
end
```

Now we run it again...

```shell
$ bundle exec cucumber features/no_argument.feature
Using the default profile...
Feature: Version Command

  Background:                           # features/no_argument.feature:3
    Given I have "go" command installed # features/step_definitions/gitsweeper_steps.rb:3
    And a build of gitsweeper           # features/step_definitions/gitsweeper_steps.rb:14
    Then the build should be present    # features/step_definitions/gitsweeper_steps.rb:8

  Scenario:                          # features/no_argument.feature:8
    Given a build of gitsweeper      # features/step_definitions/gitsweeper_steps.rb:14
    When I run `gitsweeper-int-test` # aruba-b9d0f15d1292/lib/aruba/cucumber/command.rb:3
    Then the output should contain:  # aruba-b9d0f15d1292/lib/aruba/cucumber/command.rb:213
      """
      usage: gitsweeper [<flags>] <command> [<args> ...]

      A command-line tool for cleaning up merged branches.
      """

1 scenario (1 passed)
6 steps (6 passed)
0m5.870s
```

We've now validated our app can be built and when run, gives a certain version output.

Because gitsweeper runs against git repos, we can go for a much more complex setup where we run a git repo within a Docker container, and run our gitsweeper tests against that. 

```gherkin
Feature: Cleanup Command

  Background:
    Given I have "go" command installed
    And a build of gitsweeper
    And I have "docker" command installed
    And nothings running on port "8008"

  Scenario: In a git repo with branches with force
    Given no old "gitdocker" containers exist
    And I have a dummy git server running called "gitdocker" running on port "8008"
    And I clone "http://localhost:8008/dummy-repo.git" repo
    And I cd to "dummy-repo"
    When I run `gitsweeper-int-test cleanup --force`
    Then the output should contain:
      """
      These branches have been merged into master:
        origin/duplicate-branch-1
        origin/duplicate-branch-2
      
        deleting origin/duplicate-branch-1 - (done)
        deleting origin/duplicate-branch-2 - (done)
      """
    And the exit status should be 0
```

Because Aruba is a ruby tool, we can also leverage existing Ruby libraries if we want to as well, such as the Docker gem

```ruby
Given /^no old "(\w+)" containers exist$/ do |container_name|
  begin
    app = Docker::Container.get(container_name)
    app.delete(force: true)
  rescue Docker::Error::NotFoundError
  end
end

Given /^I have a dummy git server running called "(\w+)" running on port "(\w+)"$/ do |container_name, port|
  steps %Q(
    Given no old "#{container_name}" containers exist
    When I successfully run `docker run -d -p '#{port}:80' --name='#{container_name}' petems/dummy-git-repo`
  )
  sleep 3
end

Given(/I clone "([^"]*)" repo/) do |repo_name|
  steps %Q(
    When I successfully run `git clone #{repo_name}`
  )
end

Given(/I create a bare git repo called "([^"]*)"/) do |repo_name|
  steps %Q(
    When I successfully run `git init --bare #{repo_name}`
  )
end

Given /^I add a new remote "([^"]*)" with url "([^"]*)"$/ do |new_remote, url|
  steps %Q(
    When I successfully run `git remote add #{new_remote} #{url}`
    And I successfully run `git fetch #{new_remote}`
  )
end
```

Finally, we want to make sure that we're doing a full-teardown and pre-check before the tests run to make sure we're not going to have clashes. We do this setup in our `/support/env.rb` file:

```ruby
require 'aruba/cucumber'
require 'docker'
require 'fileutils'
require 'forwardable'
require 'tmpdir'

$bin_dir = File.expand_path('../../../bin/', __FILE__)
$aruba_dir = File.expand_path('../../..', __FILE__) + '/tmp/aruba'

Aruba.configure do |config|
  # increase process exit timeout from the default of 3 seconds
  config.exit_timeout = 20
  # allow absolute paths for tests involving no repo
  config.allow_absolute_paths = true
  # don't be "helpful"
  config.remove_ansi_escape_sequences = false
end

Before do
  aruba.environment.update(
    'PATH' => "#{$bin_dir}:#{ENV['PATH']}",
  )
  FileUtils.rm_rf("#{$aruba_dir}/bare-git-repo")
  FileUtils.rm_rf("#{$aruba_dir}/dummy-repo")
  FileUtils.rm_rf("#{$bin_dir}/gitsweeper-int-test")
end

After do
  begin
    app = Docker::Container.get("gitdocker")
    app.delete(force: true)
  rescue Docker::Error::NotFoundError, Excon::Error::Socket
  end
  FileUtils.rm_rf("#{$aruba_dir}/bare-git-repo")
  FileUtils.rm_rf("#{$aruba_dir}/dummy-repo")
  FileUtils.rm_rf("#{$bin_dir}/gitsweeper-int-test")
end
```

So we're deleting any pre-existing gitsweeper build, removing git repos and making sure all docker containers are not running. 

### Alternatives

The main issue with this setup is it's a bit jarring to switch between Golang and Ruby for testing. 

I did see someone made a tool called [testcli](https://github.com/rendon/testcli), which is supposed to act similar to Aruba for golang apps. 

```golang
func TestGreetingsWithName(t *testing.T) {
	// Using the struct version, if you want to test multiple commands
	c := testcli.Command("greetings", "--name", "John")
	c.Run()
	if !c.Success() {
		t.Fatalf("Expected to succeed, but failed with error: %s", c.Error())
	}

	if !c.StdoutContains("Hello John!") {
		t.Fatalf("Expected %q to contain %q", c.Stdout(), "Hello John!")
	}
}
```

But, to me it's missing the key benefit of Aruba, which is the extensive list of helpers. It only really covers the simplest usecases, which is running a command and getting output, essentially it's just a wrapper for `os.exec`.

## Conclusion

Overall, Aruba might be a bit of an overkill tool to test CLI tools, but I've found it super useful for my usecases. Maybe as I get more comfortable with Golang I'll switch to native testing and things like `testcli` instead, but for now I'll continue using Aruba until I start having issues.