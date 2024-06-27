<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import type { DataFrame } from 'data-forge';
    import Select from 'svelte-select';

    export let df: DataFrame;
    export let changeNeg: Array<string>;
    export let changePos: Array<string>;
    export let uniqNames: Array<string>;
    
    let uniqYears = df.deflate(row => Number(row.year)).distinct().toArray().sort();

    $: selectedNames = ["Mateusz", "Nikodem", "Natalia", "Pola", ];

    let chart: echarts.EChartsType;
    let chartDiv: HTMLDivElement;

    function updateChart() {
        let traces: Array<Array<any>> = [];
        selectedNames.forEach(name => {
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
        renderChart(uniqYears, traces, selectedNames);
    }

    function renderChart(x: Array<any>, ys: Array<Array<any>>, ynames: Array<string>) {
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

        chart.setOption(option, true);   
    }

    function namesSelected(namesRaw: Array<object> | null) {
        if (namesRaw != null) {
            let names: Array<string> = namesRaw.map(el => el.value);
            // console.log(names);
            selectedNames = names;
            updateChart();
        }
    }

    onMount(async () => {
        chart = echarts.init(chartDiv);
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

<h2>Global names</h2>

<button on:click={ () => { selectedNames = changePos } }>Trend up</button>
<button on:click={ () => { selectedNames = changeNeg } }>Trand down</button>

<Select 
    items={ uniqNames }
    value={ selectedNames }
    clearable={ true }
    placeholder="Pick names"
    class="foo bar"
    on:input={ (details) => {namesSelected(details.detail)} }
    multiple
/>

<p>{ selectedNames }</p>

<div class="chart" bind:this={ chartDiv }>

</div>
