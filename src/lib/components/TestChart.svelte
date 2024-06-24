<script lang="ts">

    import { onMount } from 'svelte';

    import * as duckdb from '@duckdb/duckdb-wasm';
    import * as echarts from 'echarts';

    // export let db: Promise<duckdb.AsyncDuckDB>;
    export let db: duckdb.AsyncDuckDB;
    // export let db: string;

    let chartDiv: HTMLDivElement;

    function makeChart() {
        var myChart = echarts.init(chartDiv);
        var option: echarts.EChartOption = {
            xAxis: {
                type: 'category',
                data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
            },
            yAxis: {
                type: 'value'
            },
            series: [
                {
                data: [150, 230, 224, 218, 135, 147, 260],
                type: 'line'
                }
            ]
        };

        myChart.setOption(option);   
    }


    onMount(() => {
        makeChart();
        console.log(db)
	});

</script>

<style>
    /* todo calculate dynamically and move to more general place */
    .chart {
        width: 100%;
        height: 400px;
    }
</style>


<div class="chart" bind:this={ chartDiv }>

</div>
