export const prerender = true;
export const ssr = true;
export const csr = true;

import type { LoadEvent } from '@sveltejs/kit';
import { DataFrame } from "data-forge";
import { parquetRead, parquetMetadata, parquetSchema, type FileMetaData } from 'hyparquet';

async function getDf(event: LoadEvent, url:string): Promise<DataFrame> {
    let res: Response = await event.fetch(url);
    let arrayBuffer: ArrayBuffer = await res.arrayBuffer();
    let metadata: FileMetaData = parquetMetadata(arrayBuffer);
    let { children } = parquetSchema(metadata);
    let headers: Array<string> = children.map(child => child.element.name);
    let df: DataFrame | undefined;
    await parquetRead({
        file: arrayBuffer,
        onComplete: data => {
            df = new DataFrame({columnNames: headers, rows: data});
        }
    })
    return df as DataFrame
}


/** @type {import('./$types').PageLoad} */
export async function load(event: LoadEvent) {
	let df: DataFrame = await getDf(event, "names.parquet");

	let uniqNamesDf: DataFrame = await getDf(event, "unique_names.parquet");
	let uniqNames = uniqNamesDf.deflate(row => String(row.first_name)).toArray();
	
	let changeNegDf: DataFrame = await getDf(event, "change_neg.parquet");
	let changeNeg = changeNegDf.deflate(row => String(row.first_name)).toArray();

    let changePosDf: DataFrame = await getDf(event, "change_pos.parquet");
	let changePos = changePosDf.deflate(row => String(row.first_name)).toArray();
	
	return {
		df: df,
		uniqNames: uniqNames,
		changeNeg: changeNeg,
		changePos: changePos,
	};
}
