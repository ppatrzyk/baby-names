<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import type { DataFrame } from 'data-forge';

    export let df: DataFrame;
    export let changeNeg: Array<string>;
    export let changePos: Array<string>;
    export let uniqNames: Array<string>;

    let uniqYears = df.deflate(row => Number(row.year)).distinct().toArray().sort();

    let chartDiv: HTMLDivElement;

    function updateChart(names: Array<string>) {
        let traces: Array<Array<any>> = [];
        names.forEach(name => {
            let nameDf = df.filter(row => (row.first_name == name));
            let years = nameDf.deflate(row => Number(row.year)).toArray();
            let indexMap = uniqYears.map(year => years.includes(year));

            // todo extract to function
            // null or 0 rethink
            let counts = nameDf.deflate(row => Number(row.count)).toArray();
            let countsRev = counts.reverse();
            let countsFull = indexMap.map(index => (index ? countsRev.pop() : null));
            traces.push(countsFull);
        });
        renderChart(uniqYears, traces, names);
    }

    function renderChart(x: Array<any>, ys: Array<Array<any>>, ynames: Array<string>) {
        let chart = echarts.init(chartDiv);
        // chart.showLoading();
        let series = ys.map((y, i) => {
            let entry = {data: y, name: ynames[i], type: 'line'};
            return entry
        });
        let option: echarts.EChartOption = {
            title: {text: 'Names over time'},
            // todo other numbers shown in tooltip
            tooltip: {trigger: 'axis'},
            legend: {data: ynames},
            xAxis: {type: 'category', data: x},
            yAxis: {type: 'value'},
            series: series
        };

        chart.setOption(option);   
    }

    onMount(async () => {
        console.log(uniqNames); //todo this goes to dropdown options
        // todo this executed also on some click
        updateChart(changePos.slice(0, 10));
	});

</script>

<style>
    /* todo calculate dynamically */
    .chart {
        width: 100%;
        height: 400px;
    }
</style>

<h2>Global names</h2>

<p>todo name selectors here, changePos, changeNeg as defaults</p>

<div class="chart" bind:this={ chartDiv }>

</div>
