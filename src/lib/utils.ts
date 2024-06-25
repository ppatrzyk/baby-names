import { parquetRead, parquetMetadata, parquetSchema, type FileMetaData } from 'hyparquet';
import { DataFrame } from "data-forge";

export async function getDf(url:string): Promise<DataFrame> {
    let res: Response = await fetch(url);
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
