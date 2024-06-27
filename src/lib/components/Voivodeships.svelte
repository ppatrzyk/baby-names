<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import { DataFrame } from "data-forge";
    import Select from 'svelte-select';

    export let voivodeshipDf: DataFrame;
    export let mapJson: Object;
    export let uniqNames: Array<string>;

    let uniqYears = voivodeshipDf.deflate(row => String(row.year)).distinct().toArray().sort();
    // let uniqVoivodeships = voivodeshipDf.deflate(row => String(row.voivodeship)).distinct().toArray().sort();

    let fakeData = [
        { name: 'śląskie', value: 4822023 },
        { name: 'podlaskie', value: 731449 },
        { name: 'lubuskie', value: 731449 },
    ]

    $: selectedName = "Mateusz";
    $: selectedYear = "2023";
    $: currentOption = mapOption;
    $: currentData = fakeData;

    // let mapOption: echarts.EChartOption;
    // let barOption: echarts.EChartOption;

    let chartDiv: HTMLDivElement;
    let chart: echarts.EChartsType;

    // let currentOption: echarts.EChartOption;
    // currentOption = mapOption;

    $: mapOption = {
        visualMap: {
            left: 'right',
            // todo fix min max here, taken 0 -actual data max
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
                data: currentData
            }
        ]
    };

    $: barOption = {
        xAxis: {
            type: 'value'
        },
        yAxis: {
            type: 'category',
            axisLabel: {rotate: 30},
            data: currentData.map(function (item) {
                return item.name;
            })
        },
        animationDurationUpdate: 1000,
        series: {
            type: 'bar',
            id: 'population',
            data: currentData.map(function (item) {
                return item.value;
            }),
            universalTransition: true
        }
    };

    function updateData(name: string, year: string) {
        let nameDf = voivodeshipDf.filter(row => (row.first_name == name && row.year == Number(year)));
        let voivodeships = nameDf.deflate(row => (row.voivodeship.toLowerCase())).toArray();
        let counts = nameDf.deflate(row => Number(row.count)).toArray();
        let data = voivodeships.map((el, i) => {
            let entry = {name: el, value: counts[i]};
            return entry
        });
        currentData = data;
        // console.log(data)
    }

    function updateChart() {
        updateData(selectedName, selectedYear);
        // todo if this is necessary
        chart.setOption(currentOption);
    }

    function toggleMapBar() {
        currentOption = currentOption === mapOption ? barOption : mapOption;
        chart.setOption(currentOption, true);
    }

    function nameSelected(rawName: Object) {
        selectedName = rawName.value;
        updateChart();
    }

    function yearSelected(rawYear: Object) {
        selectedYear = rawYear.value;
        updateChart();
    }

    onMount(async () => {
        chart = echarts.init(chartDiv);
        echarts.registerMap('PL', mapJson);
        updateChart();
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

<Select 
    items={ uniqNames }
    value={ selectedName }
    clearable={ false }
    placeholder="Pick name"
    class="foo bar"
    on:input={ (details) => {nameSelected(details.detail)} }
/>

<Select 
    items={ uniqYears }
    value={ selectedYear }
    clearable={ false }
    placeholder="Pick year"
    class="foo bar"
    on:input={ (details) => {yearSelected(details.detail)} }
/>

<p>{ selectedName }</p>
<p>{ selectedYear }</p>

<button on:click={ () => toggleMapBar() }>change map/bar</button>

<div class="chart" bind:this={ chartDiv }>

</div>
