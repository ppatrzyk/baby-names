<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import type { DataFrame } from 'data-forge';
    import Select from 'svelte-select';

    export let df: DataFrame;
    export let changeNeg: Array<string>;
    export let changePos: Array<string>;
    
    let uniqNames = df.deflate(row => String(row.first_name)).distinct().toArray().sort();
    let uniqYears = df.deflate(row => Number(row.year)).distinct().toArray().sort();

    let namesDz = uniqNames.filter(name => name.toLowerCase().includes("dż"));
    let brians = ["Brian", "Brajan", "Braian", "Brayan", "Bryan"];
    let oliwiers = ["Oliwier", "Oliwer", "Oliver", "Olivier"];

    $: selectedNames = ["Mateusz", "Antoni", "Natalia", "Zofia", ];

    let chart: echarts.EChartsType;
    let chartDiv: HTMLDivElement;

    function getYTrace(df: DataFrame, indexMap: Array<boolean>, variable: string) {
        let trace = df.deflate(row => Number(row[variable])).toArray();
        let traceRev = trace.reverse();
        // null or 0 rethink
        let traceFull = indexMap.map(index => (index ? traceRev.pop() : null));
        return traceFull
    }

    function updateChart() {
        let traces: Array<Array<any>> = [];
        selectedNames.forEach(name => {
            let nameDf = df.filter(row => (row.first_name == name)) as DataFrame;
            let years = nameDf.deflate(row => Number(row.year)).toArray();
            let indexMap = uniqYears.map(year => years.includes(year));
            let countsFull = getYTrace(nameDf, indexMap, 'yearly_perc')
            // let countsFull = getYTrace(nameDf, indexMap, 'yearly_rank')
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
            tooltip: {trigger: 'axis', order: 'valueDesc'},
            legend: {data: ynames},
            xAxis: {
                data: x,
                type: 'category',
                name: 'year',
                nameGap: 30,
                nameLocation: 'middle',
                // nameTextStyle: {align: "center"}
            },
            yAxis: {
                type: 'value',
                name: '% of babies within gender',
                nameGap: 36,
                nameLocation: 'middle',
            },
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
        margin: var(--pico-typography-spacing-vertical) 0;
    }
</style>

<h2 id="ts-section">Names over time</h2>

<p>
    Name popularity over time. Pick ones that interest you, or see for example:
</p>

<ul>
    <li><a href="#ts-section" on:click={ () => { selectedNames = changePos } }>growing in popularity</a>,</li>
    <li><a href="#ts-section" on:click={ () => { selectedNames = changeNeg } }>decreasing in popularity</a>,</li>
    <li><a href="#ts-section" on:click={ () => { selectedNames = namesDz } }>names that contain <em>dż</em></a>,</li>
    <li><a href="#ts-section" on:click={ () => { selectedNames = brians } }><em>Brian</em> variations</a>.</li>
    <li><a href="#ts-section" on:click={ () => { selectedNames = oliwiers } }><em>Oliwier</em> variations</a>.</li>
</ul>

<fieldset class="grid">
    <label for="">
        Names
        <Select 
            --font-size="--pico-font-size"
            items={ uniqNames }
            value={ selectedNames }
            clearable={ true }
            placeholder="Pick names"
            class="foo bar"
            on:input={ (details) => {namesSelected(details.detail)} }
            multiple
        />
    </label>
</fieldset>

<div class="chart" bind:this={ chartDiv }>

</div>
