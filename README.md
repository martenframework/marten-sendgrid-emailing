# Marten Sendgrid Emailing

[![CI](https://github.com/martenframework/marten-sendgrid-emailing/workflows/Specs/badge.svg)](https://github.com/martenframework/marten-sendgrid-emailing/actions)
[![CI](https://github.com/martenframework/marten-sendgrid-emailing/workflows/QA/badge.svg)](https://github.com/martenframework/marten-sendgrid-emailing/actions)

**Marten Sendgrid Emailing** provides a [Sendgrid](https://sendgrid.com) backend that can be used with Marten web framework's [emailing system](https://martenframework.com/docs/next/emailing).

## Installation

Simply add the following entry to your project's `shard.yml`:

```yaml
dependencies:
  marten_sendgrid_emailing:
    github: martenframework/marten-sendgrid-emailing
```

And run `shards install` afterward.

## Configuration

First, add the following requirement to your project's `src/project.cr` file:

```crystal
require "marten_sendgrid_emailing"
```

Then you can configure your project to use the Sendgrid backend by setting the corresponding configuration option as follows:

```crystal
Marten.configure do |config|
  config.emailing.backend = MartenSendgridEmailing::Backend.new(api_key: ENV.fetch("SENDGRID_API_KEY"))
end
```

The `MartenSendgridEmailing::Backend` class needs to be initialized using a [Sendgrid API key](https://docs.sendgrid.com/ui/account-and-settings/api-keys). You should ensure that this value is kept secret and that it's not hardcoded in your config files.

If needed, it should be noted that you can enable [Sendgrid sandbox mode](https://docs.sendgrid.com/for-developers/sending-email/sandbox-mode) when initializing the backend object by setting the `sandbox_mode` argument to `true`:

```crystal
Marten.configure do |config|
  config.emailing.backend = MartenSendgridEmailing::Backend.new(api_key: ENV.fetch("SENDGRID_API_KEY"), sandbox_mode: true)
end
```

## Authors

Morgan Aubert ([@ellmetha](https://github.com/ellmetha)) and 
[contributors](https://github.com/martenframework/marten/contributors).

## License

MIT. See ``LICENSE`` for more details.
