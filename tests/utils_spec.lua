local eq = assert.are.same
local Utils = require('deneote.utils')

describe('Utils.trim', function()
  it('trims whitespace, dashes, underscores', function()
    eq(Utils.trim('-_--   foo _ -- __ '), 'foo')
  end)
end)
