#!/usr/bin/env zsh
# Mock context detection helpers for testing

# Mock Docker environment
mock_docker_setup() {
    local state="${1:-running}"
    
    # Create mock docker command
    docker() {
        local mock_state="$MOCK_DOCKER_STATE"
        case "$1" in
            ps)
                if [[ "$mock_state" == "running" ]]; then
                    echo "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS"
                    echo "abc123         nginx     nginx     1h ago    Up 1h"
                    echo "def456         redis     redis     2h ago    Up 2h"
                    return 0
                elif [[ "$mock_state" == "stopped" ]]; then
                    echo "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS"
                    return 0
                else
                    echo "Cannot connect to Docker daemon" >&2
                    return 1
                fi
                ;;
            info)
                if [[ "$mock_state" == "not-running" ]]; then
                    echo "Cannot connect to Docker daemon" >&2
                    return 1
                fi
                echo "Containers: 2"
                return 0
                ;;
            *)
                return 0
                ;;
        esac
    }
    
    # Function is automatically available in zsh
    export MOCK_DOCKER_STATE="$state"
}

# Mock Kubernetes environment
mock_k8s_setup() {
    local context="${1:-production}"
    local namespace="${2:-default}"
    
    kubectl() {
        case "$1" in
            config)
                case "$2" in
                    current-context)
                        if [[ -n "$context" ]]; then
                            echo "$context"
                            return 0
                        else
                            echo "error: current-context not set" >&2
                            return 1
                        fi
                        ;;
                    view)
                        echo "current-context: $context"
                        echo "namespace: $namespace"
                        return 0
                        ;;
                    *)
                        return 0
                        ;;
                esac
                ;;
            get)
                if [[ "$2" == "namespace" ]]; then
                    echo "$namespace"
                    return 0
                fi
                ;;
            *)
                return 0
                ;;
        esac
    }
    
    # Function is automatically available in zsh
    export MOCK_K8S_CONTEXT="$context"
    export MOCK_K8S_NAMESPACE="$namespace"
}

# Mock Python virtual environment
mock_virtualenv_setup() {
    local env_name="${1:-venv}"
    export VIRTUAL_ENV="/home/user/$env_name"
    export VIRTUAL_ENV_NAME="$env_name"
}

# Mock Conda environment
mock_conda_setup() {
    local env_name="${1:-base}"
    export CONDA_DEFAULT_ENV="$env_name"
    export CONDA_PREFIX="/opt/conda/envs/$env_name"
}

# Mock language versions
mock_language_versions() {
    # Python
    python() {
        [[ "$1" == "--version" ]] && echo "Python 3.9.5"
        return 0
    }
    
    # Node.js
    node() {
        [[ "$1" == "--version" ]] && echo "v16.14.0"
        return 0
    }
    
    # Ruby
    ruby() {
        [[ "$1" == "--version" ]] && echo "ruby 3.0.1p64"
        return 0
    }
    
    # Go
    go() {
        [[ "$1" == "version" ]] && echo "go version go1.17.5 linux/amd64"
        return 0
    }
    
    # Functions are automatically available in zsh
}

# Mock cloud provider contexts
mock_aws_setup() {
    local profile="${1:-production}"
    local region="${2:-us-west-2}"
    
    export AWS_PROFILE="$profile"
    export AWS_REGION="$region"
    
    aws() {
        case "$1" in
            sts)
                [[ "$2" == "get-caller-identity" ]] && echo '{"Account":"123456789012"}'
                ;;
            configure)
                [[ "$2" == "get" && "$3" == "region" ]] && echo "$region"
                ;;
        esac
        return 0
    }
    
    # Function is automatically available in zsh
}

mock_gcp_setup() {
    local project="${1:-my-project}"
    
    export GOOGLE_CLOUD_PROJECT="$project"
    
    gcloud() {
        case "$1" in
            config)
                [[ "$2" == "get-value" && "$3" == "project" ]] && echo "$project"
                ;;
            auth)
                [[ "$2" == "list" ]] && echo "user@example.com"
                ;;
        esac
        return 0
    }
    
    # Function is automatically available in zsh
}

mock_azure_setup() {
    local subscription="${1:-prod-subscription}"
    
    export AZURE_SUBSCRIPTION_ID="$subscription"
    
    az() {
        case "$1" in
            account)
                [[ "$2" == "show" ]] && echo "{\"name\":\"$subscription\"}"
                ;;
        esac
        return 0
    }
    
    # Function is automatically available in zsh
}

# Mock infrastructure tools
mock_terraform_setup() {
    local workspace="${1:-production}"
    
    terraform() {
        [[ "$1" == "workspace" && "$2" == "show" ]] && echo "$workspace"
        return 0
    }
    
    # Function is automatically available in zsh
    export TF_WORKSPACE="$workspace"
}

mock_ansible_setup() {
    local inventory="${1:-production}"
    
    export ANSIBLE_INVENTORY="$inventory"
    touch ansible.cfg
}

# Clean up all mocks
mock_contexts_cleanup() {
    unset -f docker kubectl python node ruby go aws gcloud az terraform 2>/dev/null || true
    unset MOCK_DOCKER_STATE MOCK_K8S_CONTEXT MOCK_K8S_NAMESPACE 2>/dev/null || true
    unset VIRTUAL_ENV VIRTUAL_ENV_NAME CONDA_DEFAULT_ENV CONDA_PREFIX 2>/dev/null || true
    unset AWS_PROFILE AWS_REGION GOOGLE_CLOUD_PROJECT AZURE_SUBSCRIPTION_ID 2>/dev/null || true
    unset TF_WORKSPACE ANSIBLE_INVENTORY 2>/dev/null || true
    [[ -f ansible.cfg ]] && rm ansible.cfg
}

# Functions are automatically available in zsh