# GitAnnounce
GitAnnounce will send messages in a [Zulip](https://zulipchat.com/) stream when you add/remove labels on a GitHub repo. 


## Usage

This engine will send out Zulip messages of the following form:

@ User Name, a `funky` label was added to your PR:  [Lets pull these changes into master](https://github.com)

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
  
  - For trigger options, select only "pull requests" and "issues". 

## Configuration

For configuration, you'll need to create a few environment variables, as follows. You'll also need to create a Zulip bot.

Zulip makes creating a bot extremely easy. Go to your Zulip account, and navigate to: `Settings > Your Bots > Add a New Bot` and make it an "Incoming Webhook" bot. [These instructions](https://zulipchat.com/api/api-keys) might be helpful.

 - `ENV["ZULIP_DOMAIN"]` is your Zulip domain. This is what shows up when you're using Zulip; i.e. where the URL is "zulip.YOURDOMAINHERE.com". Do this without spaces or capital letters, e.g. sycamoreeducation
 - `ENV["STREAM_NAME"]` is the name of the stream you'd like to post the updates to. Create this stream *before* you use the engine. e.g. "GitHub Notifications" (with the quotes, if your stream name has spaces in it)
 - `ENV["BOT_EMAIL"]` is the "email" of the bot you just made, that will post the updates.
 - `ENV["BOT_API_KEY"]` is the Zulip API key for the bot you just made.

 You'll also need to create a file in your Rails app, under `config/initializers` and name it `git_announce.rb`. In this file, create a config hash and array as shown below, and populate it with your development team's information:

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

Configure these four environment variables and the hash to match your organization and bot's info, and the engine will do the rest.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
