+++
author = "Peter Souter"
categories = ["Testing", "Tech", "ruby"]
date = 2013-11-28T12:00:00Z
description = ""
draft = false
image = "/images/2016/10/5592629831_c79b801af5_z.jpg"
slug = "capybara-not-just-for-ruby"
tags = ["Testing", "Tech", "ruby"]
title = "Capybara Smoketests: Not just for Ruby!"

+++

99% of the time, if I need to code something, my language of choice is Ruby. Nothing in particular drove me to start using it, but I was at a Java house which switched to being a Ruby house, so I changed accordingly. Since then I've been doing a lot of devops-y stuff, and a [lot](http://www.opscode.com/chef/) [of](http://puppetlabs.com/) [devops](http://www.vagrantup.com/) [tools](http://logstash.net/) are written in Ruby, so it's kinda stuck. Plus, I've grown fond of how easy it is to throw together a proof of concept together without much setup, and there are [hundreds of gems out there](https://www.ruby-toolbox.com/) that you can build on.

So, on a project I was working on recently, there was a request for some smoketests for the frontend. There was some grumbling about selenium and the like, and the headache of xpath.

Enter [Capybara](https://github.com/jnicklas/capybara).

<a href="https://www.flickr.com/photos/poco33/10251157806/" title="東武動物公園 カピバラ＆ペリカン by poco33, on Flickr"><img src="https://farm8.staticflickr.com/7329/10251157806_4769a44e19.jpg" width="500" height="500" alt="東武動物公園 カピバラ＆ペリカン"></a>
_A real-life Capybara hard at work..._

Capybara is a platform for testing web applications. It's basically some Ruby wrappers around browser based tests, that hooks into tools like Selenium and PhantomJS.

As a spike, I cooked something up for our preview environment to see what people thought.

It looked a little something like this:

<script src="https://google-code-prettify.googlecode.com/svn/loader/run_prettify.js"></script>

```prettyprint lang-ruby
require 'spec_helper'
require 'capybara'
require 'capybara/dsl'

#Set environment variables so we can login to the app with basic auth
preview_username = ENV['PREVIEW_USERNAME']
preview_password = ENV['PREVIEW_PASSWORD']

# A method to allow this spec to be extended in the future for other platforms
def switch_platform(platform, password)
  Capybara.app_host = "https://#{platform}:#{password}@#{platform}-foo.bar.co.uk"
end

describe "Preview Frontend", :type => :feature do
  it "can complete the basic happy path" do
    switch_platform(preview_username, preview_password)
    visit '/'
    click_on 'A button'
    choose 'An option'
    click_on 'Continue'
    check 'I agree'
    click_on 'Continue'
    select '1', :from => 'dob_day'
    select 'January', :from => 'dob_month'
    fill_in 'dob_year', :with => '1980'
    click_on 'Continue'
    fill_in 'name_firstName', :with => 'John'
    fill_in 'name_lastName', :with => 'Smith'
    click_on 'Continue'
    click_on 'Continue'
    fill_in 'postCode', :with => 'WR2 6NJ'
    click_on 'Find address'
    select 'Unit 4, Elgar Business Centre, Moseley Road, Hallow, Worcester, Worcestershire', :from => 'input-address-list'
    click_on 'Continue'
    click_on 'I accept'
    page.should have_content('Complete!')
    page.should have_content('Your reference number is ')
  end
end
```

Just from looking at that you can see the flow of what it's trying to achieve: You fill in your name and address, and get a reference number at the end. The Capybara DSL is very easy to understand, even for those that aren't super familiar with Ruby.

I think it explains itself a lot better than and is a lot [DRY-er](http://en.wikipedia.org/wiki/Don't_repeat_yourself) than:

```prettyprint lang-java
public class temp script extends SeleneseTestCase {
    public void setUp() throws Exception {
        setUp("http://localhost:8080/", "*iexplore");
    }
    public void testTemp script() throws Exception {
        selenium.open("/BrewBizWeb/");
        selenium.click("link=Start The BrewBiz Example");
        selenium.waitForPageToLoad("30000");
        selenium.type("name=id", "bert");
        selenium.type("name=Password", "biz");
        selenium.click("name=dologin");
        selenium.waitForPageToLoad("30000");
    }
}
```
_Taken from an [online selenium tutorial](http://www.pushtotest.com/selenium-tutorial-for-beginners-tutorial-1)_

You can also see that Capybara is clever enough that you don't have to add in `wait`'s for various elements. It will repeatably attempt to find an element or waiting for a page to load for a defined time (2 seconds by default), which helps cut down on issues with asynchronous requests.

So this was a pretty effective proof of concept I created, and could hand over to the front-end devs to extend and change as they saw fit. They did things like refactor the platform code so it could be pointed at a local instance, so they could make changes to the smoke-tests in advance when developing on the app itself.

So after that picked up some steam and the various people were happy with it, I got the tests running in Jenkins. I ended up picking the  [PhantomJS](https://github.com/ariya/phantomjs/) driver. It's headless so removes the finicky-ness of trying to setup xvfb, and there's a great Capybara-specific driver for it called [poltergeist](https://github.com/jonleighton/poltergeist).

That all worked fine, but the error messages you get weren't super helpful without context:

```
  1) Staging Frontend can complete the basic happy path
     Screenshot: ./screenshot_2013-11-27-14-01-01.173.png
     Failure/Error: click_on 'Continue'
     Capybara::ElementNotFound:
       Unable to find link or button "Continue"
     # ./spec/features/staging_happy_path_spec.rb:13:in `block (2 levels) in <top (required)>'
```

This failure was a bit strange, as looking at the code, there clearly was a button with Continue on the page.

So I added in [capybara-screenshot](https://github.com/mattheworiordan/capybara-screenshot). This automatically produces an image and the raw HTML of a page when a test fails. Combine this with [Jenkins Artifacts](https://wiki.jenkins-ci.org/display/JENKINS/ArtifactDeployer+Plugin) like so:

![Post Build archives](/content/images/2016/10/postbuild.png)

And you have a permanent copy of the raw HTML and a screenshot of the page on failure.

So let's go back to that weird failure we were getting before:

![Jenkins Screenshot](/content/images/2016/10/jenkins-1.png)

Clicking on the screenshot got me this:

![Bad Gateway Fail](/content/images/2016/10/badgateway.png)

Turns out we were changing a deployment process at the time and the app had been stopped briefly to check something. We started it up again and the test went green. All sorted!

So all-in-all, Capybara is a great tool for web-acceptance testing, even on non Rails and Ruby apps.