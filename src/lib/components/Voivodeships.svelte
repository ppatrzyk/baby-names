<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import { DataFrame } from "data-forge";

    export let df: DataFrame;
    export let mapJson: Object;
    // export let uniqNames: Array<string>;
    // todo how to pass uniq years? one general var?

    let chartDiv: HTMLDivElement;
    let chart: echarts.EChartsType;

    let fakeData = [
        { name: 'śląskie', value: 4822023 },
        { name: 'podlaskie', value: 731449 },
        { name: 'lubuskie', value: 731449 },
    ]

    let currentOption: echarts.EChartOption;

    let mapOption: echarts.EChartOption = {
        visualMap: {
            left: 'right',
            min: 500000,
            max: 38000000,
            inRange: {
                color: ['#313695', '#4575b4', '#74add1', '#abd9e9', '#e0f3f8', '#ffffbf', '#fee090', '#fdae61', '#f46d43', '#d73027', '#a50026']
            },
            text: ['High', 'Low'],
            calculable: true
        },
        series: [
            {
                id: 'test_data',
                type: 'map',
                roam: true,
                map: 'PL',
                animationDurationUpdate: 1000,
                // universalTransition: true,
                data: fakeData
            }
        ]
    };

    let barOption: echarts.EChartOption = {
        xAxis: {
            type: 'value'
        },
        yAxis: {
            type: 'category',
            axisLabel: {rotate: 30},
            data: fakeData.map(function (item) {
                return item.name;
            })
        },
        animationDurationUpdate: 1000,
        series: {
            type: 'bar',
            id: 'population',
            data: fakeData.map(function (item) {
                return item.value;
            }),
            universalTransition: true
        }
    };

    function toggleMapBar() {
        currentOption = currentOption === mapOption ? barOption : mapOption;
        chart.setOption(currentOption, true);
        // chart.setOption(barOption)
    }

    onMount(async () => {
        chart = echarts.init(chartDiv);
        echarts.registerMap('PL', mapJson);
        chart.setOption(mapOption);
        currentOption = mapOption;
	});

</script>

<style>
    /* todo calculate dynamically */
    .chart {
        width: 100%;
        height: 400px;
    }
</style>


<h2>Analysis by voivodeship</h2>

<button on:click={ () => toggleMapBar() }>change map/bar</button>

<div class="chart" bind:this={ chartDiv }>

</div>
