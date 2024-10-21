locals {
  name   = replace(basename(path.cwd), "_", "-") # basename("foo/bar/baz") //baz
  region = "ap-northeast-1"
  app    = "st-go-web-dev"
}
