<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import { parquetRead, parquetMetadata, parquetSchema, type FileMetaData } from 'hyparquet';
    import { DataFrame } from "data-forge";

    let chartDiv: HTMLDivElement;

    // TODO this outside of component, import from lib
    async function getData(url:string) {
        let res: Response = await fetch(url);
        let arrayBuffer: ArrayBuffer = await res.arrayBuffer();
        let metadata: FileMetaData = parquetMetadata(arrayBuffer);
        let { children } = parquetSchema(metadata);
        let headers: Array<string> = children.map(child => child.element.name);
        let df: DataFrame | undefined;
        await parquetRead({
            file: arrayBuffer,
            onComplete: data => {
                df = new DataFrame({columnNames: headers, rows: data});
            }
        })
        return df
    }

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


    onMount(async () => {
        let df = await getData("names.parquet") as DataFrame;
        let filtered = df.filter(row => row.first_name == 'Jan');
        // TODO cols to array and send to viz as params
        console.log(filtered.toArray());
        makeChart();
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
