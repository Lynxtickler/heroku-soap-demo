resource "heroku_app" "this" {
  name   = var.app_name
  region = "eu"
}

# Create a slug for the app with a local slug archive file
resource "heroku_slug" "this" {
  app                            = heroku_app.this.id
  buildpack_provided_description = "heroku-deploy"
  file_path                      = "packages/CloudDemo1.war"

  process_types = {
    web = "java $JAVA_OPTS -jar webapp-runner.jar ${"$"}{WEBAPP_RUNNER_OPTS} --port $PORT ./packages/CloudDemo1.war"
  }
}

# Deploy a release to the app with the slug
resource "heroku_app_release" "this" {
  app     = heroku_app.this.id
  slug_id = heroku_slug.this.id
}

# Launch the app's web process by scaling-up
resource "heroku_formation" "this" {
  app        = heroku_app.this.id
  type       = "web"
  quantity   = 1
  size       = "Standard-1x"
  depends_on = [heroku_app_release.this]
}
