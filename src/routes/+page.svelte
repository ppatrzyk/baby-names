<script lang="ts">

    /** @type {import('./$types').PageData} */
	export let data;

    import { onMount } from 'svelte';
    import TimeSeries from "$lib/components/TimeSeries.svelte";
    import Voivodeships from "$lib/components/Voivodeships.svelte";

    onMount(async () => {
        console.log("data init finished?");
	});

</script>

<style>

</style>

<h1>Polish baby names 2000-2023</h1>
<p>todo description</p>

<TimeSeries 
    df={ data.df }
    changeNeg={ data.changeNeg }
    changePos={ data.changePos }
/>

<Voivodeships 
    voivodeshipDf={ data.voivodeshipDf }
    mapJson={ data.mapJson } 
/>
