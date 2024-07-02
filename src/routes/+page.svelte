<script lang="ts">

    /** @type {import('./$types').PageData} */
	export let data;

    import { onMount } from 'svelte';
    import TimeSeries from "$lib/components/TimeSeries.svelte";
    import Voivodeships from "$lib/components/Voivodeships.svelte";
    import Ranking from '$lib/components/Ranking.svelte';

    onMount(async () => {
        // 
	});

</script>

<style>

</style>

<h1>Polish baby names 2000-2023</h1>

<p>
    <small>
        Author: <a href="https://www.patrzyk.me/">Piotr Patrzyk</a> <br>
        Source code: <a href="https://github.com/ppatrzyk/baby-names">github.com/ppatrzyk/baby-names</a> <br>
        Data source: <a href="https://dane.gov.pl/pl/dataset/219">Otwarte dane</a> (CC0 1.0)
    </small>    
</p>

<p>
    Interactive visualization of polish baby names data. 
    For names that appear in both genders, <em>[m]/[f]</em> denotes version. 
    Original data source lists only names with at least 2 occurrences in reporting area/period.
</p>

<TimeSeries 
    df={ data.df }
    changeNeg={ data.changeNeg }
    changePos={ data.changePos }
/>

<Ranking 
    df={ data.df }
/>

<Voivodeships 
    voivodeshipDf={ data.voivodeshipDf }
    voivodeshipChange={ data.voivodeshipChange }
    mapJson={ data.mapJson } 
/>
