<script lang="ts">

    import { onMount } from 'svelte';
    import type { DataFrame } from 'data-forge';
    import Select from 'svelte-select';

    export let df: DataFrame;
    
    // only string works with select component
    let uniqYears = df.deflate(row => String(row.year)).distinct().toArray().sort();
    let uniqGenders = ["male", "female", ];

    $: selectedYear = "2023";
    $: selectedGender = "male";

    function updateTable() {
        let ranking = df
            .filter(row => (row.year == Number(selectedYear) && row.gender == selectedGender))
            .subset(["first_name", "yearly_perc", "yearly_rank"])
            .orderBy(row => row["yearly_rank"]);
        let rawData = ranking.toArray();
        console.log(rawData);
    }

    function yearSelected(rawYear: Object) {
        selectedYear = rawYear.value;
        updateTable();
    }

    function genderSelected(rawGender: Object) {
        selectedGender = rawGender.value;
        updateTable();
    }

    onMount(async () => {
        // 
	});

</script>

<style>

</style>

<h2>Global ranking { selectedYear }</h2>

<Select 
    items={ uniqYears }
    value={ selectedYear }
    clearable={ true }
    placeholder="Pick year"
    class="foo bar"
    on:input={ (details) => {yearSelected(details.detail)} }
/>

<Select 
    items={ uniqGenders }
    value={ selectedGender }
    clearable={ true }
    placeholder="Pick gender"
    class="foo bar"
    on:input={ (details) => {genderSelected(details.detail)} }
/>
