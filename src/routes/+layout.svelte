<script lang="ts">
    import "@picocss/pico";
</script>

<style>
    :root {
        font-family: system-ui, sans-serif;
    }
    :global(html) {
        background-image: linear-gradient(to right bottom, rgb(255, 255, 255) , rgb(250, 250, 250));
    }
    #main-document {
        max-width: 1024px;
        width: 75%;
        margin: 4em auto 4em auto;
    }
</style>

<svelte:head>
	<title>Baby names</title>
</svelte:head>

<main id="main-document">
    <slot />
</main>
