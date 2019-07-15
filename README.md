# GitAnnounce
GitAnnounce will send messages in a [Zulip](https://zulipchat.com/) stream when someone makes changes on a GitHub PR. 

If you're interested in the code (e.g. to adapt this engine for your own needs), it lives primarily in `app/controllers/messages_controller.rb` , `app/lib/git_hub.rb`, and `app/lib/zulip.rb`.


## Usage

This engine will send out Zulip messages of the following form:

- @User Name, a `funky` label was added to your PR:  [Lets pull these changes into master](https://github.com)
- @User Name, your PR [Lets pull these changes into master](https://github.com) was approved by Michael Schneider
- @User Name, Michael Schneider requested changes on your PR [Lets pull these changes into master](https://github.com). See the comments here.

That is, it gets the user who opened the PR and tags them in a Zulip message about a change that occurred on their PR.

Key things to note: 

- It doesn't notify anyone when a user adds a label to their own PR.
- It doesn't notify anyone when a change is made by an "ignored" user (e.g. a bot, see below)

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'git_announce', git: 'https://github.com/schneider7/GitAnnounce'
```

And then execute:
```bash
$ bundle
```

Add the following `mount` line to `routes.rb`, in your Rails app:

```ruby
# Rails.application.routes.draw do
  mount GitAnnounce::Engine, at: "/git_announce"
```

Via the engine, this creates a `POST` route to handle the webhooks received at `/git_announce`.

Now set up an outgoing webhook request from GitHub **on each of the repos you'd like to "listen" to.**

  - Navigate to the page for setting up webhooks within your repo: `(Repo) Settings > Webhooks > Add Webhook` 

  - Create a new webhook, select the option for the delivery to be in JSON form: `application/json`
  
  - For the URL, point it at https://yourapp.domain/git_announce
  
  - For trigger options, select "issues", "issue comments", "pull requests", "pull request reviews", and "pull request review comments". 

## Configuration

For configuration, you'll need to create a few environment variables, as follows. You'll also need to create a Zulip bot.

Zulip makes creating a bot extremely easy. Go to your Zulip account, and navigate to: `Settings > Your Bots > Add a New Bot` and make it an "Incoming Webhook" bot. [These instructions](https://zulipchat.com/api/api-keys) might be helpful.

 - `ENV["ZULIP_DOMAIN"]` is your Zulip domain. Since our Zulip URL is `http://zulip.sycamoreeducation.com`, our Zulip domain is sycamoreeducation. This should have no spaces or capital letters.
 - `ENV["STREAM_NAME"]` is the name of the stream you'd like to post the updates to. Create this stream *before* you use the engine. e.g. "GitHub Notifications" (with the quotes, if your stream name has spaces in it).
 - `ENV["BOT_EMAIL"]` is the "email" of the bot you just made, that will post the updates.
 - `ENV["BOT_API_KEY"]` is the Zulip API key for the bot you just made.
 - `ENV["GITHUB_TOKEN"]` is the GitHub API access key you want to use. This is necessary because if your organization's repos are private, the `GET` requests done by GitAnnounce will fail unless you provide this authentication.

 You'll also need to create a file in your Rails app, under `config/initializers` and name it `git_announce.rb`. In this file, create both a config hash and array as shown below, and populate it with your development team's information:

 ```ruby
GitAnnounce.developers = {
  schneider7: "Michael Schneider",
  githubusername: "Firstname Lastname",
  user3: "Johnny Test"
}

# Ignoring changes made automatically by bots. Usually changes made by 
# bots aren't worth notifying someone about, because they were small to begin with.
GitAnnounce.ignore = ["bot_account1", "bot_account2"]

```

 This is so that the GitHub usernames will get matched to the real names of the developers, which will make the Zulip messages more human-readable. **Make sure that the full names defined by this hash are the same as the full names used in Zulip.** For example, if I had written "Mike Schneider" as my name in the hash, the engine wouldn't properly tag me in Zulip messages, because my name there is set up as "Michael Schneider".

Configure these five environment variables and the hash to match your organization and bot's info, and the engine will do the rest.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
