mageops::bootstrap::__module__() 
  lib::import ui
  lib::import mageops::core
  lib::import mageops::ansible

  mageops::bootstrap::project-vars-install() {
    true # Not implemented
  }
  
  mageops::bootstrap::install() {
    chmod +x $MAGEOPS_ROOT/bin/*

    ln -snvf \
        $MAGEOPS_ROOT/bin/* \
        /usr/local/bin/

    mkdir -pv \
        $MAGEOPS_ROOT/ansible

    git clone \
        --depth 5 \
        --single-branch \
        --branch "${MAGEOPS_ANSIBLE_BRANCH}" \
            https://github.com/mageops/ansible-infrastructure.git \
                $MAGEOPS_ROOT/ansible/infrastructure

    git clone \
        https://github.com/mageops/ansible-infrastructure-vars.git \
            $MAGEOPS_ROOT/ansible/infrastructure-vars

    mkdir -pv \
        $MAGEOPS_ROOT/ansible/infrastructure/vars/global \
        $MAGEOPS_ROOT/ansible/infrastructure/vars/local \
        $MAGEOPS_ROOT/ansible/infrastructure/vars/project \
        $MAGEOPS_ROOT/ansible/infrastructure/tmp

    rm -rf \
        $MAGEOPS_ROOT/ansible/infrastructure/vars/project/

    ln -snvf \
        $MAGEOPS_ROOT/ansible/infrastructure-vars/project-raccoon/ \
        $MAGEOPS_ROOT/ansible/infrastructure/vars/project

    virtualenv-3 $MAGEOPS_ROOT/ansible/virtualenv

    source $MAGEOPS_ROOT/ansible/virtualenv/bin/activate

    pip install \
        -r $MAGEOPS_ROOT/ansible/infrastructure/requirements-python.txt

    ansible-galaxy install \
        -r $MAGEOPS_ROOT/ansible/infrastructure/requirements-galaxy.yml \
        -p $MAGEOPS_ROOT/ansible/infrastructure/roles

    mkdir -p $MAGEOPS_ROOT/ansible/bin
  }
}