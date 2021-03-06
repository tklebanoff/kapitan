local statefulset = import "./statefulset.jsonnet";
local headless_service = import "./service.jsonnet";
local kube = import "lib/kube.libjsonnet";
local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local secret = import "./secret.jsonnet";

local name = inv.parameters.mysql.instance_name;

{
  local c = self,
  mysql_statefulset: statefulset.MySQLStatefulSet(name, self.mysql_secret),
  mysql_secret: secret.MySQLSecret(name),
  mysql_secret_subvar: secret.MySQLSecret_subvar(name),


  // The following is an example to show how you can use a simple json file
  // and simply inject variables from the inventory, a-la helm
  mysql_service_simple: headless_service,

  // Or you can use jsonnet and discover what you need from the deployment itself.
  mysql_service_jsonnet: kube.Service(name + "-jsonnet") {
      target_pod:: c["mysql_statefulset"].spec.template,
      target_container_name:: "mysql"} { spec+: { clusterIP: "None" }},
}
