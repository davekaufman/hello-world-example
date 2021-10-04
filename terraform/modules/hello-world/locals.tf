locals {
  # default to 1 task per subnet
  desired_count = length(aws_subnet.public.*.id)
  region        = data.aws_region.current.name
}
