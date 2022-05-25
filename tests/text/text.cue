import "text/template"

#Config: {
	param1: string
	param2: int
	param3: [string]: string
}

data: #Config
tmpl: "{{ .param1 }}"
rendered: template.Execute(tmpl, data)