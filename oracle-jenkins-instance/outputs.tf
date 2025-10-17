output "jenkins_public_ip" {
  value = oci_core_instance.jenkins.public_ip
}

output "jenkins_web_url" {
  value       = "http://${oci_core_instance.jenkins.public_ip}:8080"
  description = "Web URL to access Jenkins"
}

output "jenkins_ssh_command" {
  value       = "ssh ubuntu@${oci_core_instance.jenkins.public_ip}"
  description = "SSH command to connect to the instance"
}