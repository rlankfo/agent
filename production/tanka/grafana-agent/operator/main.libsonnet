
local apiVersion = {
    apiVersion: 'monitoring.grafana.com/v1alpha1'
};

{
  grafanaAgent: {
    new(config={}):: {
      local this = self,
      _config:: {
	    name: 'grafana-agent',
      	namespace: 'default',
      	image: 'grafana/agent:v0.22.0',
      	logLevel: 'info',
      	serviceAccount: 'grafana-agent',
      } + config,
      kind: 'GrafanaAgent',
      metadata: {
	    name: this._config.name,
	    namespace: this._config.namespace,
      },
      spec: {
        image: this._config.image,
        logLevel: this._config.logLevel,
        serviceAccountName: this._config.serviceAccount,
      },
    } + apiVersion,
    withLabels(labels={}):: {
        metadata+: {
            labels+: labels,
        },
    },
    withMetrics(matchLabels={}, externalLabels={}):: {
        spec+: {
            metrics: {
                instanceSelector: {
                    matchLabels: matchLabels,
                },
                externalLabels: externalLabels,
            },
        },
    },
    withLogs(matchLabels={}):: {
        spec+: {
            logs: {
                instanceSelector: {
                    matchLabels: matchLabels,
                }
            }
        },
    },
  },
  metricsInstance: {
    new(config={}):: {
        local this = self,
        _config:: {
            name: 'primary',
            namespace: 'default',
            credSecretName: 'primary-credentials-metrics',
        } + config,
        kind: 'MetricsInstance',
        metadata: {
            name: this._config.name,
            namespace: this._config.namespace,
        },
        spec: {
            remoteWrite: [
                {
                    url: config.remoteWriteURL,
                    // TODO: basicAuth should be optional
                    basicAuth: {
                        username: {
                            name: this._config.credSecretName,
                            key: 'username',
                        },
                        password: {
                            name: this._config.credSecretName,
                            key: 'password',
                        },
                    },
                },
            ],
        },
        // TODO: Supply an empty namespace selector to look in all namespaces. Remove
        // TODO: this to only look in the same namespace as the MetricsInstance
        serviceMonitorNamespaceSelector: {},
        serviceMonitorSelector: {},

        // TODO: podMonitorNamespaceSelector, podMonitorSelector
        // TODO: probeNamespaceSelector, probeSelector
    } + apiVersion + $.metricsInstance.withServiceMonitorMatchLabels(),
    withLabels(labels={}):: {
        metadata+: {
            labels+: labels,
        },
    },
    withServiceMonitorMatchLabels(labels={ instance: 'primary' }):: {
        serviceMonitorSelector+: {
            matchLabels: labels,
        },
    }
  },
}



