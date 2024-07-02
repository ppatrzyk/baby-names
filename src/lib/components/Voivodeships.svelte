<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import { DataFrame } from "data-forge";
    import Select from 'svelte-select';

    export let voivodeshipDf: DataFrame;
    export let voivodeshipChange: Array<String>;
    export let mapJson: Object;
    
    // todo better scale
    let COLORS = [
        "#fde725",
        "#7ad151",
        "#22a884",
        "#2a788e",
        "#414487",
        '#440154',
    ].reverse();

    let uniqNames = voivodeshipDf.deflate(row => String(row.first_name)).distinct().toArray().sort();
    // only string works with select component
    let uniqYears = voivodeshipDf.deflate(row => String(row.year)).distinct().toArray().sort();

    $: selectedName = "Mateusz";
    $: selectedYear = "2023";
    $: currentOption = "map";
    $: currentData = updateData(selectedName, selectedYear);

    let chartDiv: HTMLDivElement;
    let chart: echarts.EChartsType;

    function updateData(name: string, year: string) {
        let nameDf = voivodeshipDf.filter(row => (row.first_name == name && row.year == Number(year)));
        let voivodeships = nameDf.deflate(row => (row.voivodeship.toLowerCase())).toArray();
        let perc = nameDf.deflate(row => Number(row.yearly_perc)).toArray();
        let data = voivodeships.map((el, i) => {
            let entry = {name: el, value: perc[i]};
            return entry
        });
        // currentData = data;
        return data
    }

    function updateChart() {
        currentData = updateData(selectedName, selectedYear);
        if (currentData.length == 0) {
            alert('no data')
            return false
        }
        let option: echarts.EChartOption;
        if (currentOption == "map") {
            let values = currentData.map(el => el.value);
            option = {
                visualMap: {
                    left: 'right',
                    min: Math.min(...values),
                    max: Math.max(...values),
                    inRange: {color: COLORS},
                    text: ['% of babies', ''],
                    calculable: true
                },
                tooltip: {trigger: 'item'},
                series: [
                    {
                        id: 'perc_year',
                        name: '% of babies within gender',
                        type: 'map',
                        roam: true,
                        map: 'PL',
                        animationDurationUpdate: 1000,
                        data: currentData
                    }
                ]
            };
        } else {
            option = {
                xAxis: {
                    type: 'value',
                    name: '% of babies within gender',
                    nameGap: 30,
                    nameLocation: 'middle',
                },
                yAxis: {
                    type: 'category',
                    inverse: true,
                    axisLabel: {rotate: 30},
                    data: currentData.map(function (item) {
                        return item.name;
                    })
                },
                tooltip: {trigger: 'axis', order: 'valueDesc', },
                animationDurationUpdate: 1000,
                series: {
                    type: 'bar',
                    color: '#0172ad',
                    id: 'yearly_perc',
                    realtimeSort: true,
                    data: currentData.map(function (item) {
                        return item.value;
                    }),
                    universalTransition: true
                }
            };
        }
        option.title = {text: `${selectedName} (${selectedYear})`, textStyle: {fontSize: '24px'}};
        chart.setOption(option, true);
        return true
    }

    function toggleMapBar() {
        currentOption = currentOption === "map" ? "bar" : "map";
        updateChart();
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
        height: 800px;
        margin: var(--pico-typography-spacing-vertical) 0;
    }

</style>

<h2 id="voivodeships-section">Popularity by voivodeship</h2>

<p>
    Prevalence of name { selectedName } in { selectedYear }. Names having biggest variability across locations in 2023 include:
    {#each voivodeshipChange as name}
        <span><a href="#voivodeships-section" on:click={ () => { selectedName = name } }>{ name }</a>, </span>
    {/each}
</p>

<fieldset class="grid">
    <label for="">
        Name
        <Select 
            --font-size="--pico-font-size"
            items={ uniqNames }
            value={ selectedName }
            clearable={ false }
            placeholder="Pick name"
            class="foo bar"
            on:input={ (details) => {nameSelected(details.detail)} }
        />
    </label>

    <label for="">
        Year
        <Select 
            --font-size="--pico-font-size"
            items={ uniqYears }
            value={ selectedYear }
            clearable={ false }
            placeholder="Pick year"
            class="foo bar"
            on:input={ (details) => {yearSelected(details.detail)} }
        />
    </label>
</fieldset>

<button on:click={ () => toggleMapBar() }>change chart type [map/bar]</button>

<div class="chart" bind:this={ chartDiv }>

</div>
