export const prerender = true;
export const ssr = false;
export const csr = true;

import type { LoadEvent } from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export async function load(event: LoadEvent) {
	return {
		test: 666
	};
}
