local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local kustomize = tanka.kustomize.new(std.thisFile);
local operator = import 'grafana-agent/operator/main.libsonnet';
local a = operator.grafanaAgent;
local m = operator.metricsInstance;

{
    install: kustomize.build(path='crds'),

    grafanaAgent: a.new(config={
        namespace: 'smoke',
    })
    + a.withLabels({
        app: 'grafana-agent',
    })
    + a.withMetrics({
        agent: 'grafana-agent-metrics',
    }, {
        cluster: 'cloud',
    })
    + a.withLogs({
        agent: 'grafana-agent-logs',
    }),

    metricsInstance: m.new(config={
        namespace: 'smoke',
        remoteWriteURL: 'http://cortex/api/prom/push',
    })
    + m.withLabels({
        agent: 'grafana-agent-metrics',
    }),


}
