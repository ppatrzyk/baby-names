<script lang="ts">

    /** @type {import('./$types').PageData} */
	export let data;

    // let db: Promise<duckdb.AsyncDuckDB>;
    let db: duckdb.AsyncDuckDB;
    // let db: string = "todo_change_me";

    import { onMount } from 'svelte';
    import TestChart from "$lib/components/TestChart.svelte";

    import * as duckdb from '@duckdb/duckdb-wasm';
    import duckdb_wasm from '@duckdb/duckdb-wasm/dist/duckdb-mvp.wasm?url';
    import mvp_worker from '@duckdb/duckdb-wasm/dist/duckdb-browser-mvp.worker.js?url';
    import duckdb_wasm_eh from '@duckdb/duckdb-wasm/dist/duckdb-eh.wasm?url';
    import eh_worker from '@duckdb/duckdb-wasm/dist/duckdb-browser-eh.worker.js?url';
    const MANUAL_BUNDLES: duckdb.DuckDBBundles = {
        mvp: {
            mainModule: duckdb_wasm,
            mainWorker: mvp_worker,
        },
        eh: {
            mainModule: duckdb_wasm_eh,
            mainWorker: eh_worker,
        },
    };

    async function initDb() {
        // Select a bundle based on browser checks
        const bundle = await duckdb.selectBundle(MANUAL_BUNDLES);
        // Instantiate the asynchronus version of DuckDB-wasm
        const worker = new Worker(bundle.mainWorker!);
        const logger = new duckdb.ConsoleLogger();
        const db = new duckdb.AsyncDuckDB(logger, worker);
        await db.instantiate(bundle.mainModule, bundle.pthreadWorker);
        return db
    }

    onMount(async () => {
        console.log(data.test);
        db = await initDb();
        console.log("data init finished?");
	});

</script>

<style>

</style>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://kit.svelte.dev">kit.svelte.dev</a> to read the documentation</p>

<TestChart db={ db } />

<!-- todo passing db from here does not work, undefined and load too long -->