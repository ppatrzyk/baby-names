<script lang="ts">

    import { onMount } from 'svelte';
    import * as echarts from 'echarts';
    import { DataFrame } from "data-forge";

    let chartDiv: HTMLDivElement;

    onMount(async () => {
        // todo choropleth map and line chart 
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

<div class="chart" bind:this={ chartDiv }>

</div>
