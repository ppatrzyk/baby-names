<script lang="ts">

    /** @type {import('./$types').PageData} */
	export let data;

    import { onMount } from 'svelte';
    import Totals from "$lib/components/Totals.svelte";
    import Voivodeships from "$lib/components/Voivodeships.svelte";

    onMount(async () => {
        console.log(data.defaultNames);
        console.log("data init finished?");
	});

</script>

<style>

</style>

<h1>Polish baby names 2000-2023</h1>
<p>todo description</p>

<Totals df={ data.df } defaultNames={ data.defaultNames } uniqNames={ data.uniqNames }/>
<Voivodeships />
