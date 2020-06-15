import { Inject, Injectable } from '@angular/core';
import { Provider } from '@ngeth/provider';
import { Auth, AUTH } from '@ngeth/auth';
import {
  BlockTag,
  TxLogs,
  ITxObject,
  TxObject,
  hexToNumber,
  hexToNumberString
} from '@ngeth/utils';
import { Observable, BehaviorSubject } from 'rxjs';
import { map, filter } from 'rxjs/operators';
import { Eth } from '@ngeth/provider';

@Injectable({ providedIn: 'root' })
export class ContractProvider {
  private currentTx = new BehaviorSubject<Partial<ITxObject>>(null);
  public tx$ = this.currentTx.asObservable();
  public id: number;

  constructor(
    @Inject(AUTH) private auth: Auth,
    private provider: Provider,
    private eth: Eth
  ) {
    this.id = this.provider.id;
    this.auth.account$
      .pipe(
        filter(from => !!from),
      )
      .subscribe(
        from =>
          (this.defaultTx = {
            ...this.defaultTx,
            from: from
          })
      );
  }

  get defaultTx(): Partial<ITxObject> {
    return this.currentTx.getValue();
  }

  set defaultTx(transaction: Partial<ITxObject>) {
    const tx = { ...this.currentTx.getValue(), ...transaction };
    this.currentTx.next(tx);
  }

  /**
   * Make a call to the node
   * @param to The address of the contract to contact
   * @param data The data of the call as bytecode
   * @param blockTag The block to target
   */
  public call<T>(
    to: string,
    data: string,
    blockTag: BlockTag = 'latest'
  ): Observable<T> {
    return this.provider.rpc<T>('eth_call', [{ to, data }, blockTag]);
  }

  /**
   * Send a transaction to the node
   * @param tx The transaction to pass to the node
   * @param blockTag The block to target
   * @return the hash of the transaction
   */
  public sendTransaction(
    transaction: Partial<ITxObject>,
    ...rest: any[]
  ): Observable<any> {
    const tx = new TxObject(transaction);
    return this.auth.sendTransaction(tx, rest);
  }

  /**
   * Create a RPC request for a subscription
   * @param address The address of the contract
   * @param topics The signature of the event
   */
  public event(address: string, topics: string[]): Observable<TxLogs> {
    return this.provider
      .rpcSub<TxLogs>(['logs', { address, topics }])
      .pipe(map(logs => new TxLogs(logs)));
  }

  /**
   * Estimate the amount of gas needed for transaction
   * @param transaction The transaction to estimate the gas from
   */
  public estimateGas(transaction: Partial<ITxObject>): Observable<string> {
    const tx = new TxObject(transaction);
    return this.provider.rpc<string>('eth_estimateGas', [tx]).pipe(
      map((gas: string) => {
        const gasMax = 4700000;//4.700.000 max for ropsten
        const estimateGas = hexToNumber(gas.replace('0x', ''));
        const gasToReturn = estimateGas * 1.5 > gasMax ? estimateGas : estimateGas * 1.5;
        return gasToReturn.toString();
      }),
    );
    // multiplied by 1.5 to avoid under-estimation
  }

  /**
   * Returns the current price per gas in wei
   */
  public gasPrice(): Observable<string> {
    return this.provider
      .rpc<string>('eth_gasPrice', [])
      .pipe(map((price: string) => hexToNumberString(price.replace('0x', ''))));
  }

  public getNonce() : Observable<string> {
    return this.provider
    .rpc<string>('eth_getTransactionCount', [this.defaultTx.from, 'latest'])
    .pipe(map((nonce: string) => hexToNumberString(nonce.replace('0x', ''))));
    // return this.eth.getTransactionCount(this.defaultTx.from);
  }
  
}
