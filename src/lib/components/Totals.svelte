<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import type { DataFrame } from 'data-forge';

    export let df: DataFrame;
    export let defaultNames: Array<string>;
    export let uniqNames: Array<string>;

    let chartDiv: HTMLDivElement;

    function makeChart(x: Array<any>, ys: Array<Array<any>>) {
        var myChart = echarts.init(chartDiv);
        let series = ys.map(y => {
            let entry = {data: y, type: 'line'};
            return entry
        });
        var option: echarts.EChartOption = {
            xAxis: {type: 'category', data: x},
            yAxis: {type: 'value'},
            series: series
        };

        myChart.setOption(option);   
    }

    onMount(async () => {
        console.log(defaultNames);
        console.log(uniqNames); //todo this goes to dropdown options
        
        // todo create list of y 'traces' for each defaultNames
        let filtered = df.filter(row => row.first_name == 'Jan');
        let years = filtered.deflate(row => Number(row.year)).toArray();
        let counts = filtered.deflate(row => Number(row.count)).toArray();
        makeChart(years, [counts, ]);
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

<div class="chart" bind:this={ chartDiv }>

</div>
