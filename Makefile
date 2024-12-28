#
# SPDX-License-Identifier: GPL-3.0-or-later

SHELL=bash
PREFIX ?= /usr/local
SOLIDITY_COMPILER_BACKEND ?= solc
_PROJECT=evm-openpgp-keyserver
_KS_NAME=KeyServer
_KS_SOL=$(_KS_NAME).sol
_KS_ABI=$(_KS_NAME).abi.json
_KS_BYTECODE=$(_KS_NAME).bin
_KS_JSON=$(_KS_NAME).json
_CONTRACTS_PATH=contracts
_KS_DIR=$(_CONTRACTS_PATH)/$(_KS_NAME)
_KS_DIRS=$(wildcard $(_KS_DIR)/*)
_KS_VERSIONS=$(filter-out deployments,$(notdir $(_KS_DIRS)))
_KS_DEPLOYMENTS_DIR=$(_KS_DIR)/deployments
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/$(_PROJECT)
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
LIB_DIR=$(DESTDIR)$(PREFIX)/lib/$(_PROJECT)
BUILD_DIR=build
CONTRACTS_BUILD_WORK_DIR=contracts-build

DEPLOYED_NETWORKS_CONFIG_DIR=$(wildcard $(_KS_DEPLOYMENTS_DIR)/*)
DEPLOYED_NETWORKS=$(notdir $(DEPLOYED_NETWORKS_CONFIG_DIR))
DOC_FILES=\
  $(wildcard *.rst) \
  $(wildcard *.md)
SCRIPT_FILES=$(wildcard $(_PROJECT)/*)

_INSTALL_FILE=install -Dm644
_INSTALL_EXE=install -Dm755
_INSTALL_CONTRACTS_DEPLOYMENT_FUN:=\
  install-contracts-deployments-$(SOLIDITY_COMPILER_BACKEND)
_BUILD_TARGETS:=\
  contracts
_BUILD_TARGETS_ALL:=\
  all \
  $(_BUILD_TARGETS)
_CHECK_TARGETS:=\
  shellcheck
_CHECK_TARGETS_ALL:=\
  check \
  $(_CHECK_TARGETS)
_CLEAN_TARGETS_ALL:=\
  clean
_INSTALL_CONTRACTS_TARGETS:=\
  $(_INSTALL_CONTRACTS_DEPLOYMENT_FUN) \
  install-contracts-deployments-config \
  install-contracts-sources
_INSTALL_CONTRACTS_TARGETS_ALL:=\
  install-contracts \
  install-contracts-deployments-hardhat \
  install-contracts-deployment-solc \
  install-contracts-deployments-config \
  install-contracts-sources
_INSTALL_TARGETS:=\
  install-doc \
  $(_INSTALL_CONTRACTS_TARGETS) \
  install-scripts
_INSTALL_TARGETS_ALL:=\
  install \
  install-doc \
  $(_INSTALL_CONTRACTS_TARGETS_ALL) \
  install-scripts
_PHONY_TARGETS:=\
  $(_BUILD_TARGETS_ALL) \
  $(_CHECK_TARGETS_ALL) \
  $(_CLEAN_TARGETS_ALL) \
  $(_INSTALL_TARGETS_ALL)

all: $(_BUILD_TARGETS)

install: $(_INSTALL_TARGETS)

check: $(_CHECK_TARGETS)

install-contracts: $(_INSTALL_CONTRACTS_TARGETS)

clean:

	rm \
	  -rf \
	  "$(BUILD_DIR)"

shellcheck:

	shellcheck \
	  -s \
	    bash \
	  $(SCRIPT_FILES);

contracts:

	for _network in $(DEPLOYED_NETWORKS); do \
	  _deployment_dir="$(_KS_DEPLOYMENTS_DIR)/$${_network}"; \
	  _config_file="$${_deployment_dir}/config.sh"; \
	  source \
	    "$${_config_file}"; \
	for _version in "$${!contract_address[@]}"; do \
	    _deployment="$${_network}/$${_version}"; \
	    _build_dir="$(BUILD_DIR)/$${_deployment}"; \
	    _work_dir="$${_build_dir}/build"; \
	    mkdir \
	      -p \
	      "$${_work_dir}"; \
	    _build="true"; \
	    if [[ "$(SOLIDITY_COMPILER_BACKEND)" == "solc" ]]; then \
	      if [[ -e "$${_build_dir}/$(_KS_ABI)" ]] && \
	         [[ -e "$${_build_dir}/$(_KS_BYTECODE)" ]]; then \
		 _build="false"; \
	      fi; \
	    elif [[ "$(SOLIDITY_COMPILER_BACKEND)" == "hardhat" ]]; then \
	      if [[ -e "$${_build_dir}/contracts/$(_KS_SOL)/$(_KS_JSON)" ]]; then \
		 _build="false"; \
	      fi; \
	    fi; \
	    if [[ "$${_build}" == "true" ]]; then \
	      solidity-compiler \
	        -v \
	        -b \
	          "$(SOLIDITY_COMPILER_BACKEND)" \
	        -C \
	          $${solc_version["$${_version}"]} \
	        -e \
	          "$${evm_version["$${_version}"]}" \
	        -w \
	          "$${_work_dir}" \
	        -o \
	          "$${_build_dir}" \
	        "$(_KS_DIR)/$${_version}/$(_KS_SOL)"; \
	    fi; \
	  done; \
	done

install-contracts-sources:

	for _version in $(_KS_VERSIONS); do \
	  $(_INSTALL_FILE) \
	    "$(_KS_DIR)/$${_version}/$(_KS_SOL)" \
	    "$(LIB_DIR)/contracts/$(_KS_NAME)/$${_version}/$(_KS_SOL)"; \
	done

install-contracts-deployments-config:

	for _network in $(DEPLOYED_NETWORKS); do \
	  _deployment_dir="$(_KS_DEPLOYMENTS_DIR)/$${_network}"; \
	  _config_file="$${_deployment_dir}/config.sh"; \
	  _install_dir="$(LIB_DIR)/deployments/$(_KS_NAME)/$${_network}"; \
	  $(_INSTALL_FILE) \
	    "$${_deployment_dir}/config.sh" \
	    "$${_install_dir}/config.sh"; \
	done

install-contracts-deployments-solc:

	for _network in $(DEPLOYED_NETWORKS); do \
	  _deployment_dir="$(_KS_DEPLOYMENTS_DIR)/$${_network}"; \
	  _config_file="$${_deployment_dir}/config.sh"; \
	  source \
	    "$${_config_file}"; \
	  for _version in "$${!contract_address[@]}"; do \
	    _deployment="$${_network}/$${_version}"; \
	    _build_dir="$(BUILD_DIR)/$${_deployment}"; \
	    _install_dir="$(LIB_DIR)/deployments/$(_KS_NAME)/$${_deployment}"; \
	    $(_INSTALL_FILE) \
	      "$${_build_dir}/$(_KS_ABI)" \
	      "$${_install_dir}/$(_KS_ABI)"; \
	    $(_INSTALL_FILE) \
	      "$${_build_dir}/$(_KS_BYTECODE)" \
	      "$${_install_dir}/$(_KS_BYTECODE)"; \
	  done; \
	done

install-contracts-deployments-hardhat:

	for _network in $(DEPLOYED_NETWORKS); do \
	  _deployment_dir="$(_KS_DEPLOYMENTS_DIR)/$${_network}"; \
	  _config_file="$${_deployment_dir}/config.sh"; \
	  source \
	    "$${_config_file}"; \
	  for _version in "$${!contract_address[@]}"; do \
	    _deployment="$${_network}/$${_version}"; \
	    _build_dir="$(BUILD_DIR)/$${_deployment}"; \
	    _install_dir="$(LIB_DIR)/deployments/$(_KS_NAME)/$${_deployment}"; \
	    $(_INSTALL_FILE) \
	      "$${_build_dir}/contracts/$(_KS_SOL)/$(_KS_JSON)" \
	      "$${_install_dir}/$(_KS_JSON)"; \
	  done; \
	done

install-doc:

	$(_INSTALL_FILE) \
	  $(DOC_FILES) \
	  -t $(DOC_DIR);

install-scripts:

	$(_INSTALL_EXE) \
	  "$(_PROJECT)/evm-openpgp-key-publish" \
	  "$(BIN_DIR)/evm-openpgp-key-publish";
	$(_INSTALL_EXE) \
	  "$(_PROJECT)/evm-openpgp-key-receive" \
	  "$(BIN_DIR)/evm-openpgp-key-receive";

.PHONY: $(_PHONY_TARGETS)
