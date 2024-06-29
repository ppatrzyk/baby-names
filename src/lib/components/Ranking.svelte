<script lang="ts">

    import { onMount } from 'svelte';
    import type { DataFrame } from 'data-forge';
    import Select from 'svelte-select';
    import {DataTable} from "simple-datatables"

    export let df: DataFrame;
    
    // only string works with select component
    let uniqYears = df.deflate(row => String(row.year)).distinct().toArray().sort();
    let uniqGenders = ["male", "female", ];

    let dataTable: DataTable;

    $: selectedYear = "2023";
    $: selectedGender = "male";

    function updateTable() {
        // todo sorting fails here on percent col
        let ranking = df
            .filter(row => (row.year == Number(selectedYear) && row.gender == selectedGender))
            .subset(["yearly_rank", "first_name", "yearly_perc"])
            .orderBy(row => row["yearly_rank"]);
        let data = {
            "headings": ranking.getColumnNames(),
            "data": ranking.toRows(),
        }
        try {
            dataTable.destroy();
        } catch (error) {
            // ok, on initial render
        }
        dataTable = new DataTable("#ranking-table", {
            data: data,
            perPage: 20,
            perPageSelect: false,
            classes: {
                // top: "pure-form",
                // bottom: "datatable-container",
                // table: "pure-table pure-table-striped",
                // search: "datatable-search bottom-margin",
                // dropdown: "datatable-dropdown bottom-margin"
            },
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

<div id="ranking-table">

</div>