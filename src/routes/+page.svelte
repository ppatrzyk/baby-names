<script lang="ts">

    /** @type {import('./$types').PageData} */
	export let data;

    import { onMount } from 'svelte';
    import TestChart from "$lib/components/TestChart.svelte";

    onMount(async () => {
        console.log(data.test);
        console.log("data init finished?");
	});

</script>

<style>

</style>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://kit.svelte.dev">kit.svelte.dev</a> to read the documentation</p>

<TestChart />
