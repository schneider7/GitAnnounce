# GitAnnounce
GitAnnounce will send messages in a [Zulip](https://zulipchat.com/) stream when you add/remove labels on a GitHub repo. 

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

Configure these four environment variables to match your organization's info, and the engine will do the rest.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
