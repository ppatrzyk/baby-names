<script lang="ts">

    import { onMount } from 'svelte';
    import type { DataFrame } from 'data-forge';
    import Select from 'svelte-select';
    import {DataTable} from "simple-datatables"

    export let df: DataFrame;
    
    // only string works with select component
    let uniqYears = df.deflate(row => String(row.year)).distinct().toArray().sort();
    let uniqGenders = ["male", "female", ];

    let table: HTMLElement;
    let dataTable: DataTable;

    $: selectedYear = "2023";
    $: selectedGender = "male";

    function updateTable() {
        let ranking = df
            .filter(row => (row.year == Number(selectedYear) && row.gender == selectedGender))
            .subset(["yearly_rank", "first_name", "yearly_perc"])
            .orderBy(row => row["yearly_rank"])
            .renameSeries({"yearly_rank": "Ranking", "first_name": "First name", "yearly_perc": "% of babies"});
        let data = {
            "headings": ranking.getColumnNames(),
            "data": ranking.toRows(),
        }
        table.replaceChildren();
        dataTable = new DataTable(table, {
            data: data,
            sortable: false,
            perPage: 20,
            perPageSelect: false,
            classes: {table: "striped mytable", },
        });
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
        updateTable();
	});

</script>

<style>
    .mytable {
        margin: 0;
    }
</style>

<h2>Yearly ranking { selectedYear }</h2>

<p>Ranking for { selectedGender } names in { selectedYear }.</p>

<fieldset class="grid">
    <label for="">
        Year
        <Select 
            --font-size="--pico-font-size"
            items={ uniqYears }
            value={ selectedYear }
            clearable={ true }
            placeholder="Pick year"
            class="foo bar"
            on:input={ (details) => {yearSelected(details.detail)} }
        />
    </label>

    <label for="">
        Gender
        <Select 
            --font-size="--pico-font-size"
            items={ uniqGenders }
            value={ selectedGender }
            clearable={ true }
            placeholder="Pick gender"
            class="foo bar"
            on:input={ (details) => {genderSelected(details.detail)} }
        />
    </label>
</fieldset>

<div bind:this={ table }>

</div>