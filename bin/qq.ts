import util from "util";
import { exec as exec_raw } from "child_process";
import sqs

const exec = util.promisify(exec_raw);
const endpoint = "http://localhost:9324";
const queue =
  "http://localhost:9324/000000000000/offline-costbasisServiceDLQ.fifo";

function getCmdRoot() {
  return `aws --endpoint-url ${endpoint} sqs`;
}

function randomMessage() {
    return `Message--[${Date.now()}]`;
}

function getCmdStuff(f: string): [string, (s: string) => string] {
  switch (f) {
    case undefined:
      throw "need a flag";
    case "l":
      return [`list-queues`, (s) => JSON.parse(s).QueueUrls];
    case "s":
      return [`send-message --queue-url ${queue} --message-body "${randomMessage()}" --message `, (s) => s];
    default:
      throw "dont know that flag";
  }
}

(function () {
  const f = process.argv?.[2];
  const root = getCmdRoot();
  const [end, parse] = getCmdStuff(f);
  exec(`${root} ${end}`).then((obj) => console.log(parse(obj.stdout)));
})();
