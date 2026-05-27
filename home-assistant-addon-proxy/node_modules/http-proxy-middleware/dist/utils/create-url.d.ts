import { URL } from 'url';
type CreateUrlParams = {
    protocol?: string;
    host?: string;
    port?: string;
    path?: string;
};
export declare function createUrl({ protocol, host, port, path }: CreateUrlParams): URL;
export {};
