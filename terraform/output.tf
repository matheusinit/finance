output "vm_instance_ip" {
  value = aws_instance.finance_web_vm.public_ip
}

output "elb_dns_name" {
  value = aws_elb.finance_web_elb.dns_name
}
