#!/usr/bin/env bash

if [[ ! -d "node_modules/@wojtekmaj" ]]; then
  echo "Installing React testing dependencies"
  pnpm i -D @wojtekmaj/enzyme-adapter-react-17 \
    @testing-library/jest-dom \
    enzyme \
    jest \
    react-test-renderer \
    regenerator-runtime
fi

if [[ ! -f "./testConfig.js" ]]; then
  echo 'testConfig.js not found. Creating a new one.'

echo 'import "@testing-library/jest-dom/extend-expect";
import "regenerator-runtime/runtime";

import { configure, shallow } from "enzyme";
import Adapter from "@wojtekmaj/enzyme-adapter-react-17";

configure({ adapter: new Adapter() });

global.window = {
  location: {
    pathname: "/",
  },
  innerWidth: 1200,
  addEventListener: new Function(),
};

window.shallow = shallow;

' > ./testConfig.js

fi

if [[ ! -f "./jest.config.js" ]]; then
  echo 'jest.config.js not found. Creating a new one.'

echo 'module.exports = {
  testPathIgnorePatterns: ["<rootDir>/node_modules", "<rootDir>/test"],
  globals: {},
  testEnvironment: "jsdom",
};' > ./jest.config.js

fi
