output "vm_instance_ip" {
  value = aws_instance.finance_web_vm.public_ip
}
