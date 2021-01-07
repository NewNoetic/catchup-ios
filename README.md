# Ketchup iOS (formally CatchUp)

## Develop
For all code-related concerns continue as if the name of the app is still "CatchUp".

For all user-facing concerns, use "Ketchup".

## Deploy

```bash
export GEM_HOME=/Users/sg/.gem
export PATH="$GEM_HOME/bin:$PATH"
```

`gem install bundler:2.2.0`
`bundle install`

Beta:
`bundle exec fastlane ios beta`

AppStore:
`bundle exec fastlane ios release`
