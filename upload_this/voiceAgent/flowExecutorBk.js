const { functionRegistry } = require("./functionRegistry");
const { getValueByPath, evaluateCondition } = require("./utils");

async function executeFlowForFunction(loadedFlow, functionName, initialArgs) {
  if (!loadedFlow) {
    return {
      instruct:
        "check the response if success or failed and act as per the response",
      data: { error: "No flow loaded" },
    };
  }

  const startingEdge = loadedFlow.edges.find(
    (edge) =>
      edge.source === "1" && edge.sourceHandle === `function-${functionName}`
  );
  if (!startingEdge) {
    return {
      instruct:
        "check the response if success or failed and act as per the response",
      data: { error: `No flow connected for function: ${functionName}` },
    };
  }

  let currentNodeId = startingEdge.target;
  let params = initialArgs;
  const accumulatedData = [];
  const previousResponses = [];

  // console.log(
  //   `Initial OpenAI args for ${functionName}: ${JSON.stringify(initialArgs)}`
  // );
  if (Object.keys(initialArgs).length === 0) {
    console.warn("No arguments received from OpenAI function call.");
  }

  while (currentNodeId) {
    const currentNode = loadedFlow.nodes.find(
      (node) => node.id === currentNodeId
    );
    if (!currentNode) break;

    const nodeParams = {
      currentNode: currentNode?.data,
      paramsValue: params,
      previousResponses: [...previousResponses],
      ai: { ...initialArgs },
    };

    console.log(
      `Node params for node ${currentNodeId} (${
        currentNode.type
      }): ${JSON.stringify(nodeParams)}`
    );

    let nodeResponse;
    let nextEdge;

    switch (currentNode.type) {
      case "sendMessage":
        nodeResponse = await functionRegistry.send_message(nodeParams);
        nextEdge = loadedFlow.edges.find(
          (edge) => edge.source === currentNodeId
        );
        break;
      case "sendEmail":
        nodeResponse = await functionRegistry.send_email(nodeParams);
        nextEdge = loadedFlow.edges.find(
          (edge) => edge.source === currentNodeId
        );
        break;
      case "conditional":
        // console.log(`🔀 Evaluating conditional node: ${currentNode.id}`);
        const pathToEvaluate = currentNode.data.variableName;
        let valueToEvaluate = getValueByPath(nodeParams, pathToEvaluate);

        valueToEvaluate =
          valueToEvaluate !== undefined && valueToEvaluate !== null
            ? String(valueToEvaluate)
            : valueToEvaluate;

        // console.log(`Path: ${pathToEvaluate}, Value: ${valueToEvaluate}`);

        let matchedCondition = null;
        for (const condition of currentNode.data.conditions || []) {
          if (condition.type === "default" || !condition.type) {
            // console.log(
            //   `Skipping condition: ${condition.name || condition.id} (type: ${
            //     condition.type || "undefined"
            //   })`
            // );
            continue;
          }
          const isMatch = evaluateCondition(valueToEvaluate, condition);
          // console.log(
          //   `Evaluating condition "${condition.name || condition.id}" (type: ${
          //     condition.type
          //   }, value: ${condition.value}): ${
          //     isMatch ? "Matched" : "Did not match"
          //   }`
          // );
          if (isMatch) {
            matchedCondition = condition;
            // console.log(
            //   `✅ Matched condition: ${condition.name || condition.id}`
            // );
            break;
          }
        }

        if (!matchedCondition) {
          matchedCondition = currentNode.data.conditions.find(
            (c) => c.type === "default"
          );
          if (matchedCondition) {
            // console.log(
            //   `⚠️ Using default condition: ${
            //     matchedCondition.name || "Default"
            //   }`
            // );
          } else {
            console.warn("No conditions matched and no default found.");
            nodeResponse = {
              instruct:
                "check the response if success or failed and act as per the response",
              data: { error: "No matching condition or default found" },
            };
            break;
          }
        }

        nextEdge = loadedFlow.edges.find(
          (edge) =>
            edge.source === currentNodeId &&
            edge.sourceHandle === `condition-${matchedCondition?.id}`
        );

        if (!nextEdge) {
          console.warn(`No edge found for condition: ${matchedCondition?.id}`);
          nodeResponse = {
            instruct:
              "check the response if success or failed and act as per the response",
            data: { error: "No connected edge for matched condition" },
          };
          break;
        }

        nodeResponse = {
          instruct: "Condition evaluation result",
          data: {
            condition: matchedCondition?.name || "Unknown",
            value: valueToEvaluate,
          },
        };
        break;
      case "apiCall":
        nodeResponse = await functionRegistry.api_call(nodeParams);
        nextEdge = loadedFlow.edges.find(
          (edge) => edge.source === currentNodeId
        );
        break;
      default:
        nodeResponse = {
          instruct:
            "check the response if success or failed and act as per the response",
          data: { error: `Unsupported node type: ${currentNode.type}` },
        };
        nextEdge = loadedFlow.edges.find(
          (edge) => edge.source === currentNodeId
        );
        break;
    }

    if (nodeResponse?.data) {
      accumulatedData.push(nodeResponse.data);
      previousResponses.push(nodeResponse.data);
    }

    if (!nextEdge) break;
    if (nodeResponse?.data) {
      params = nodeResponse.data || {};
    }

    currentNodeId = nextEdge.target;
  }

  return {
    instruct:
      "check the response if success or failed and act as per the response",
    data: accumulatedData,
  };
}

module.exports = {
  executeFlowForFunction,
};
