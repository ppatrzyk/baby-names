<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import { getDf } from "$lib/utils";
    import { DataFrame } from "data-forge";

    let chartDiv: HTMLDivElement;

    function makeChart(x: Array<any>, y: Array<any>) {
        var myChart = echarts.init(chartDiv);
        var option: echarts.EChartOption = {
            xAxis: {
                type: 'category',
                data: x
            },
            yAxis: {
                type: 'value'
            },
            series: [
                {
                data: y,
                type: 'line'
                }
            ]
        };

        myChart.setOption(option);   
    }


    onMount(async () => {
        let df: DataFrame = await getDf("names.parquet");

        let uniqNamesDf: DataFrame = await getDf("unique_names.parquet");
        let uniqNames = uniqNamesDf.deflate(row => String(row.first_name)).toArray();
        console.log(uniqNames)
        
        let defaultNamesDf: DataFrame = await getDf("change20202023.parquet");
        let defaultNames = defaultNamesDf.deflate(row => String(row.first_name)).toArray();
        console.log(defaultNames)
        
        let filtered = df.filter(row => row.first_name == 'Jan');
        let years = filtered.deflate(row => Number(row.year)).toArray();
        let counts = filtered.deflate(row => Number(row.count)).toArray();
        makeChart(years, counts);
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
