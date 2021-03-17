resource "aws_ssm_document" "ssm_document" {
  content       = templatefile("${path.module}/templates/${var.content_template}.json.tpl", var.template_parameters)
  document_type = var.document_type
  name          = var.document_name
}
