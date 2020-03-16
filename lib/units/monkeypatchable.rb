module Units
  module Monkeypatchable
    def monkeypatch!(into:)
      into.include(self)
    end
  end
end
