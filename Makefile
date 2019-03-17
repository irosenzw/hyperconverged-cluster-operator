CMD="kubectl"
CDI_OPERATOR_URL=$(curl --silent "https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest" | grep browser_download_url | grep "cdi-operator.yaml\"" | cut -d'"' -f4)
KUBEVIRT_OPERATOR_URL=$(curl --silent "https://api.github.com/repos/kubevirt/kubevirt/releases/latest" | grep browser_download_url | grep "kubevirt-operator.yaml\"" | cut -d'"' -f4)


if [ "${CMD}" == "kubectl" ]; then
    # create namespaces
    kubectl create ns kubevirt
    kubectl create ns cdi

    # switch namespace to kubevirt
    kubectl config set-context $(kubectl config current-context) --namespace=kubevirt

    # Deploy HCO manifests
    kubectl create -f deploy/
    kubectl create -f deploy/crds/hco_v1alpha1_hyperconverged_crd.yaml
    kubectl create -f deploy/crds/hco_v1alpha1_hyperconverged_cr.yaml

    # Create kubevirt-operator
    kubectl create -f "${KUBEVIRT_OPERATOR_URL}"

    # Create cdi-operator
    kubectl create -f "${CDI_OPERATOR_URL}"
else
    # Create projects
    oc new-project kubevirt
    oc new-project cdi

    # Switch project to kubevirt
    oc project kubevirt

    # Deploy HCO manifests
    oc create -f deploy/
    oc create -f deploy/crds/hco_v1alpha1_hyperconverged_crd.yaml
    oc create -f deploy/crds/hco_v1alpha1_hyperconverged_cr.yaml

    # Create kubevirt-operator
    oc create -f "${KUBEVIRT_OPERATOR_URL}"

    # Create cdi-operator
    oc create -f "${CDI_OPERATOR_URL}"
fi